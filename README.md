# isoinfo

A set of scripts to generate /static/isoinfo.json.

## Dependencies

* coreutils (from GNU, not BusyBox)
* bash (v4.0+)
* jq (v1.5+)

## JSON schema

```typescript
DistroObject[]
```

### DistroObject

```typescript
{
    "name": string,
    "files": DistroFileObject[],  // Sorted by version, newest first
    "latest": string  // Latest version
}
```

#### DistroFileObject

Checksums are obtained from files like sha256sums.txt, not by executing checksum programs on the files.

```typescript
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

