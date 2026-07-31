#!/usr/bin/env bash
set -eu

cd "$(dirname "${BASH_SOURCE[0]}")"

download_and_extract() {
  local archive_name=$1
  local archive_url=$2
  local source_dir=$3

  wget --no-verbose --output-document="${archive_name}" "${archive_url}"
  mkdir -p "${source_dir}"
  tar -xf "${archive_name}" \
    -C "${source_dir}" \
    --strip-components=1
}

download_and_extract \
  ADIOS2-v2.12.1.tar.gz \
  https://github.com/ornladios/ADIOS2/archive/refs/tags/v2.12.1.tar.gz \
  sources/adios/ADIOS2-2.12.1
download_and_extract \
  CGAL-6.1.1.tar.xz \
  https://github.com/CGAL/cgal/releases/download/v6.1.1/CGAL-6.1.1.tar.xz \
  sources/cgal/CGAL-6.1.1
download_and_extract \
  boost_1_74_0.tar.bz2 \
  https://archives.boost.io/release/1.74.0/source/boost_1_74_0.tar.bz2 \
  sources/boost/boost_1_74_0
download_and_extract \
  fftw-3.3.10.tar.gz \
  https://www.fftw.org/fftw-3.3.10.tar.gz \
  sources/fftw/fftw-3.3.10
download_and_extract \
  scotch-v6.1.0.tar.gz \
  https://gitlab.inria.fr/scotch/scotch/-/archive/v6.1.0/scotch-v6.1.0.tar.gz \
  sources/scotch/scotch_6.1.0
download_and_extract \
  KaHIP-v3.15.tar.gz \
  https://github.com/KaHIP/KaHIP/archive/refs/tags/v3.15.tar.gz \
  sources/kahip/kahip-3.15
