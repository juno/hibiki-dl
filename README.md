# Hibiki Radio Station downloader

## Prerequisits

* ffmpeg (Install via Homebrew)
* ruby 2.3.0

```console
$ brew install ffmpeg --with-openssl
```

## Usage

```console
$ bundle install --path .bundle
$ bundle exec ruby hibiki.rb <access_id> [output_dir]
```

Output filename is like a "imas_cg.mp4".

## Example

```console
$ bundle exec ruby hibiki.rb imas_cg .
```

