# Developer install — Iteration 1 (stub filter + queue)

This procedure registers a **development** Canon PIXMA G3010 queue on **macOS Tahoe** (or other CUPS-based macOS) using the stub filter from Iteration 1. Jobs are accepted and discarded by the filter; nothing is sent to the printer yet.

## Prerequisites

- Build tools: Xcode Command Line Tools (`xcode-select --install`).
- CMake 3.20+ and Ninja (recommended) or Unix Makefiles.

## Build

From the repository root:

```bash
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build
ctest --test-dir build --output-on-failure
```

If you use Xcode generator, set `CMAKE_RUNTIME_OUTPUT_DIRECTORY` or run tests from the configuration-specific output directory; **Ninja** is the default recommendation for predictable `build/g3010_filter` paths.

## Install filter and PPD (paths expected by the PPD)

The bundled [`ppd/Canon-G3010.ppd`](../ppd/Canon-G3010.ppd) references this filter path:

`/usr/local/libexec/cups/filter/g3010_filter`

```bash
sudo mkdir -p /usr/local/libexec/cups/filter
sudo cp build/g3010_filter /usr/local/libexec/cups/filter/g3010_filter
sudo chmod 755 /usr/local/libexec/cups/filter/g3010_filter
sudo mkdir -p /usr/local/share/cups/model
sudo cp ppd/Canon-G3010.ppd /usr/local/share/cups/model/Canon-G3010.ppd
```

To use a different prefix, edit the `*cupsFilter` line in the PPD copy to match your install path, or use `cmake --install` with `CMAKE_INSTALL_PREFIX` and adjust paths consistently.

## Register a print queue

Replace `PRINTER_IP` with your printer’s LAN address (the stub does not talk to it yet; the URI is only so CUPS accepts the queue):

```bash
sudo lpadmin -p G3010-Stub -E \
  -v socket://PRINTER_IP:9100 \
  -P /usr/local/share/cups/model/Canon-G3010.ppd \
  -o printer-is-shared=false
```

Alternatively use a dummy URI for local-only testing:

```bash
sudo lpadmin -p G3010-Stub -E \
  -v ipp://localhost/ignore \
  -P /usr/local/share/cups/model/Canon-G3010.ppd \
  -o printer-is-shared=false
```

## Verify

- **System Settings → Printers & Scanners** (or **Print** dialog in an app): **G3010-Stub** should appear.
- **CLI:** `lpstat -p G3010-Stub`

Send a test job (filter consumes input and exits 0):

```bash
echo "%PDF-1.4" | lp -d G3010-Stub -o document-format=application/pdf
```

Check `lpstat -o` until the job completes; failures usually show in Console / `cups` error log.

## Remove the test queue

```bash
sudo lpadmin -x G3010-Stub
```

## Iteration 1 acceptance mapping

- **CI green:** GitHub Actions runs configure, build, and `ctest` on push/PR.
- **Manual:** After the steps above, the printer **queue** is visible in the standard print UI on Tahoe; physical printing is not required for this iteration.
