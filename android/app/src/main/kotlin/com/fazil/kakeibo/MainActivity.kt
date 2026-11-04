package com.fazil.kakeibo

import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity is required by local_auth for the biometric prompt.
class MainActivity : FlutterFragmentActivity() {
    private var pendingPick: MethodChannel.Result? = null

    // Automatic backups (PRD FR-73) go to a folder the user picks once, through
    // the Storage Access Framework, so no storage permission is needed.
    private val pickFolder = registerForActivityResult(ActivityResultContracts.OpenDocumentTree()) { uri ->
        val result = pendingPick ?: return@registerForActivityResult
        pendingPick = null
        if (uri == null) {
            result.success(null)
            return@registerForActivityResult
        }
        contentResolver.takePersistableUriPermission(
            uri,
            Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION,
        )
        result.success(mapOf("uri" to uri.toString(), "name" to folderName(uri)))
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "kakeibo/backup_folder")
            .setMethodCallHandler(::onCall)
    }

    private fun onCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "pick" -> {
                    pendingPick?.success(null)
                    pendingPick = result
                    pickFolder.launch(null)
                }
                "hasAccess" -> result.success(hasAccess(Uri.parse(call.argument<String>("uri")!!)))
                "write" -> {
                    val tree = Uri.parse(call.argument<String>("uri")!!)
                    write(tree, call.argument<String>("name")!!, call.argument<ByteArray>("bytes")!!)
                    result.success(null)
                }
                "prune" -> {
                    val tree = Uri.parse(call.argument<String>("uri")!!)
                    result.success(prune(tree, call.argument<String>("prefix")!!, call.argument<Int>("keep")!!))
                }
                "release" -> {
                    val uri = Uri.parse(call.argument<String>("uri")!!)
                    if (hasAccess(uri)) {
                        contentResolver.releasePersistableUriPermission(
                            uri,
                            Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION,
                        )
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            result.error("backup_folder", e.message, null)
        }
    }

    private fun hasAccess(tree: Uri) = contentResolver.persistedUriPermissions.any {
        it.uri == tree && it.isWritePermission
    }

    private fun folderUri(tree: Uri): Uri =
        DocumentsContract.buildDocumentUriUsingTree(tree, DocumentsContract.getTreeDocumentId(tree))

    private fun folderName(tree: Uri): String {
        contentResolver.query(
            folderUri(tree),
            arrayOf(DocumentsContract.Document.COLUMN_DISPLAY_NAME),
            null, null, null,
        )?.use { if (it.moveToFirst()) return it.getString(0) }
        return tree.lastPathSegment ?: "Backup folder"
    }

    private fun write(tree: Uri, name: String, bytes: ByteArray) {
        val doc = DocumentsContract.createDocument(contentResolver, folderUri(tree), "application/json", name)
            ?: throw IllegalStateException("Couldn't create $name")
        contentResolver.openOutputStream(doc, "w")!!.use { it.write(bytes) }
    }

    /** Deletes the oldest files whose names start with [prefix], keeping [keep]. */
    private fun prune(tree: Uri, prefix: String, keep: Int): Int {
        val children = DocumentsContract.buildChildDocumentsUriUsingTree(
            tree, DocumentsContract.getTreeDocumentId(tree),
        )
        val files = mutableListOf<Pair<String, String>>()
        contentResolver.query(
            children,
            arrayOf(
                DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            ),
            null, null, null,
        )?.use { c ->
            while (c.moveToNext()) {
                val name = c.getString(1) ?: continue
                if (name.startsWith(prefix) && name.endsWith(".json")) files += c.getString(0) to name
            }
        }
        // Names carry the date and time, so sorting by name is oldest first.
        val old = files.sortedBy { it.second }.dropLast(keep)
        for ((id, _) in old) {
            DocumentsContract.deleteDocument(contentResolver, DocumentsContract.buildDocumentUriUsingTree(tree, id))
        }
        return old.size
    }
}
