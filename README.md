# WecOptTool Documentation

## Compile Instructions

### Setup Sphinx (One Time Only)

Install [Anaconda Python](https://www.anaconda.com/distribution/)

Create the Sphinx environment

```
> conda create -n _sphinx pip sphinx sphinx_rtd_theme colorama future
> activate _sphinx
(_sphinx) > pip install sphinxcontrib-matlabdomain
(_sphinx) > conda deactivate _sphinx
>
```

### Build Locally
The make process clones a copy of the master branch and then uses this to quote snippets of code.
Docs are built in the `_build` directory.

#### Windows
This uses the instructions in `make_www_local.bat`.

```
> cd path/to/WecOptTool
> make_www_local
```

#### OSX
This uses the instructions in `makefile`.

```bash
> cd path/to/WecOptTool
> make html
```

## License

[CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)
