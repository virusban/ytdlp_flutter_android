from android.content import Context
from android.net import Uri
from java.io import OutputStream

def open_output_stream(context: Context, folder_uri: str, filename: str):
    resolver = context.getContentResolver()
    tree = Uri.parse(folder_uri)

    doc = android.provider.DocumentsContract.createDocument(
        resolver,
        tree,
        "application/octet-stream",
        filename
    )

    return resolver.openOutputStream(doc)
