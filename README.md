# action-cloudsmith-upload-packages

Github action for uploading packages to Cloudsmith, borrowing heavily from
Brad Cowie's action-bintray-upload-debian-packages
(https://github.com/wanduow/action-bintray-upload-debian-packages)

## Inputs

### `path`

**Required** Path to a directory full of packages with the following structure:

```
distro_version1/*.[deb|rpm]
distro_version2/*.[deb|rpm]
distro_versionN/*.[deb|rpm]
```

Packages in the `distro_version/` directory (e.g. `debian_buster`,
`ubuntu_focal`, `centos_8`, `fedora_32`) will be uploaded to that particular
version of the distribution.

### `repo`

**Required** The Cloudsmith repository to upload to

### `username`

**Required** The Cloudsmith username to use for authentication

### `api_key`

**Required** The Cloudsmith API key to use for authentication

## Example usage

```
uses: wanduow/action-cloudsmtih-upload-packages@v1
with:
  path: packages/
  repo: salcock/libtrace
  username: libtrace-maintainer
  api_key: ${{ secrets.CLOUDSMITH_API_KEY }}
```

