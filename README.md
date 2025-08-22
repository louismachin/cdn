## Functionality

- To return a list of files in a directory
``GET /list/<path>``
``e.g /list/my/file/path``

- To return a webpage of files in a directory
``GET /view/<path>``
``e.g /view/my/file/path``

- To download a file or tar-ball of a directory
``GET /download/<path>``
OR
``GET /dl/<path>``
``e.g /download/my/file/path.txt``
``e.g /dl/my/file/alt.json``
``e.g /download/my/dir/path (returns .tar.gz)``