# Contributing

This repository is for my own use and I'm not expecting any interest in it,
but you never know.

Feel free to open issues with bugs or feature requests or send pull requests.

I will try to act on your feedback but I can't make any promises.

See [TODO.md](./TODO.md) for feature ideas.


## Development

Remember to use `lf` instead of `crlf` for newline when manually updating module hashes (for instance when not using `Update-ScoopPSManifest` or pipelines). Otherwise the generated hashes inside the scoop jsons might not match the files inside the repo (which are all using `lf`). Set your local repo to `git config core.autocrlf false` to avoid the hassle.
