# Hostex

Hostex is a simple storage solution for web. It simply handles uploads and downloads of files.

## Installation

### Docker

Simply run a Hostex service with the following command.

```
docker run -d \
           -p4001:4001 \
	   -v /local/storage/path:/var/hostex \
	   -e HOSTEX_UPLOAD_TOKEN=asecrettokenhere \
	   alisinabh/hostex
```

Please change `/local/storage/path` to a path on your system for the files to get stored. And choose a random string (You can probably just bang on your keyboard a few times) for `HOSTEX_UPLOAD_TOKEN`. This is later used when you try to upload files from your backend.

#### Environment variables

 - `HOSTEX_UPLOAD_TOKEN`: A string token for use as a Authorization Bearer token when uploading files.
 - `HOSTEX_STORAGE_PATH`: The path which hostex will use to store its data. Defaults to `/var/hostex`.
 - `HOSTEX_URL_RAND_SIZE`: Byte size of the url random generated in HOSTEX. Increasing it will give you more space. Defaults to `8`(bytes). 

## Hostex API

### Uploading a file [POST /]

Just send a HTTP POST multipart request with your file and Authorization header. The Authorization header should be in the following format.

  + Request (multipart/form-data)

    + Headers

	        Authorization: Bearer HOSTEX_UPLOAD_TOKEN
    
	+ Attributes
	  
	  - file: File to upload

  + Response 200 (application/json)

    + Attributes (object)

	  - url: /2020-08-03/asdf1234/filename.jpg (string) - Relative file path.
	  - mime: image/jpeg (string) MIME type of the uploaded file

### Get a file [GET /{url}]


  + Parameters

    - url: /2020-08-03/asdf1234/filename.jpg (string) - The url which Hostex returned during upload request.

  + Request
    
  + Response 200 (FILE_MIME)




