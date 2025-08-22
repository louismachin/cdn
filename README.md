# API Endpoints

## List Files

List files and directories at a specified path.

```http
GET /list/{path}
```

### Parameters

- `path` - The directory path to list contents from

### Example Requests

```http
GET /list/documents
GET /list/projects/my-app/src
GET /list/home/user/downloads
```

### Response

Returns a JSON object containing the success status and array of files and folders:

```json
{
  "success": true,
  "files": ["folder/", "foo.txt", "bar.txt"]
}
```

## Download Files/Directories

Download a file or directory from the specified path.

```http
GET /download/{path}
GET /dl/{path}
```

### Parameters

- `path` - The path to the file or directory to download (supports nested paths)

### Example Requests

Download a directory (returns `.tar.gz`):
```http
GET /dl/projects/my-app
GET /download/documents/reports
```

Download a file:
```http
GET /dl/documents/report.pdf
GET /download/config/settings.json
```

### Response

- **Directory**: Returns a `.tar.gz` compressed archive of the directory
- **File**: Returns the file directly