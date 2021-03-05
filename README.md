# pass-botp

A [pass](https://www.passwordstore.org/) extension for managing TOTP Backup Codes.
Fork of [msmol/pass-botp](https://github.com/msmol/pass-botp) with modified
storage format, support for storing backup codes inside the normal password
files, and more compliant code.

## Usage

```
$ pass botp
Usage: pass botp [--clip,-c] pass-name
```

For `pass-botp` to work, the backup codes must be stored in your passwords file
with the following restrictions:

1. The backup codes MUST be listed one by line at the end of the file.
2. The backup codes MUST only be listed after a "botp:" header line.
3. Each backup code must be prefixed with four spaces.

Example file _website.gpg_:

```
<password>
login: <login>
botp:
    # 111 111
    222 222
    333 333
    444 444
```

`pass-botp` will provide you with the first non-commented line, and then comment
that line out:

```
$ pass botp website
222 222
```

_website.gpg_ will now be:

```
<password>
login: <login>
botp:
    # 111 111
    # 222 222
    333 333
    444 444
```

On each subsequent run, `pass-botp` will give the next available backup code
(in this case, `333 333`) until none remain.

## Copying to clipboard

Simply add `-c` or `--clip`

```
$ pass botp -c website
Copied Backup code for website to clipboard. Will clear in $PASSWORD_STORE_CLIP_TIME seconds.
```

## Install

Copy the [src/botp.bash](src/botp.bash) file into your pass extensions
directory (usually `/usr/lib/password-store/extensions/`).
