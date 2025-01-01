# Hibiki Radio Station downloader

## Prerequisits

* ffmpeg
* ruby 3.4

```console
$ brew install ffmpeg
```

## Usage

```console
$ bundle install
$ bundle exec ruby hibiki.rb <access_id> [output_dir]
```

Output filename is like a "imas_cg.mp4".

## Example

```console
$ bundle exec ruby hibiki.rb imas_cg .
```

