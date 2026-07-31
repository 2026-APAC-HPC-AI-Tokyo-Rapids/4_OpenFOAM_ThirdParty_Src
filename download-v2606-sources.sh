#!/usr/bin/env bash
set -euo pipefail

: "${SOURCE_ARCHIVE_CACHE_DIR:?}"

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SOURCES_DIR="${THIRDPARTY_SOURCES_DIR:-${SCRIPT_DIR}/sources}"
declare -a DOWNLOAD_TEMP_FILES=()

cleanup() {
  local status=$?
  trap - EXIT INT TERM
  if ((${#DOWNLOAD_TEMP_FILES[@]})); then
    rm -f -- "${DOWNLOAD_TEMP_FILES[@]}"
  fi
  exit "${status}"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

download_archive() {
  local archive_name=$1
  local archive_url=$2
  local archive_path="${SOURCE_ARCHIVE_CACHE_DIR}/${archive_name}"
  local download_tmp

  if [[ -e "${archive_path}" ]]; then
    if [[ ! -s "${archive_path}" ]] || ! tar -tf "${archive_path}" >/dev/null; then
      echo "The cached source archive is invalid: ${archive_path}" >&2
      return 1
    fi
    echo "Using cached ${archive_path}"
    return 0
  fi

  download_tmp="${archive_path}.download.${GITHUB_RUN_ID:-manual}.${BASHPID}"
  DOWNLOAD_TEMP_FILES+=("${download_tmp}")
  wget --no-verbose --output-document="${download_tmp}" "${archive_url}"
  tar -tf "${download_tmp}" >/dev/null

  # Publish with a hardlink so concurrent jobs cannot expose a partial archive.
  if ln "${download_tmp}" "${archive_path}" 2>/dev/null; then
    echo "Cached ${archive_path}"
  elif [[ ! -s "${archive_path}" ]] || ! tar -tf "${archive_path}" >/dev/null; then
    echo "Another download created an invalid cache entry: ${archive_path}" >&2
    return 1
  else
    echo "Another job cached ${archive_path}"
  fi

  rm -f -- "${download_tmp}"
}

extract_source() {
  local archive_name=$1
  local source_subdir=$2
  local source_dir="${SOURCES_DIR}/${source_subdir}"

  install -d "${source_dir}"
  tar -xf "${SOURCE_ARCHIVE_CACHE_DIR}/${archive_name}" \
    -C "${source_dir}" \
    --strip-components=1
}

install -d -m 2775 "${SOURCE_ARCHIVE_CACHE_DIR}" "${SOURCES_DIR}"

download_archive \
  ADIOS2-v2.12.1.tar.gz \
  https://github.com/ornladios/ADIOS2/archive/refs/tags/v2.12.1.tar.gz
download_archive \
  CGAL-6.1.1.tar.xz \
  https://github.com/CGAL/cgal/releases/download/v6.1.1/CGAL-6.1.1.tar.xz
download_archive \
  boost_1_74_0.tar.bz2 \
  https://archives.boost.io/release/1.74.0/source/boost_1_74_0.tar.bz2
download_archive \
  fftw-3.3.10.tar.gz \
  https://www.fftw.org/fftw-3.3.10.tar.gz
download_archive \
  scotch-v6.1.0.tar.gz \
  https://gitlab.inria.fr/scotch/scotch/-/archive/v6.1.0/scotch-v6.1.0.tar.gz
download_archive \
  KaHIP-v3.15.tar.gz \
  https://github.com/KaHIP/KaHIP/archive/refs/tags/v3.15.tar.gz

extract_source ADIOS2-v2.12.1.tar.gz adios/ADIOS2-2.12.1
extract_source CGAL-6.1.1.tar.xz cgal/CGAL-6.1.1
extract_source boost_1_74_0.tar.bz2 boost/boost_1_74_0
extract_source fftw-3.3.10.tar.gz fftw/fftw-3.3.10
extract_source scotch-v6.1.0.tar.gz scotch/scotch_6.1.0
extract_source KaHIP-v3.15.tar.gz kahip/kahip-3.15
