# Direct download info JSON

```json
DistroObject[]
```

## DistroObject

```json
{
    "name": string,
    "files": DistroFileObject[]  // Sorted by version, newest first
}
```

### DistroFileObject

Checksums are obtained from files like sha256sums.txt, not by executing checksum programs on the files.

```json
{
    "ver": string,
    "base": string,  // Base file name that is displayed on the site
    "url": string,
    "sha256"?: string,
    "sha1"?: string,
    "md5"?: string,
    "sig"?: string,  // Signature file, URL
}
```

