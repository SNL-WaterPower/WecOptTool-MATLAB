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

### Build Locally (Windows)

```
> cd path/to/WecOptTool
> make_www_local
```

Docs are built in the `_build` directory.

## License

[CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)
