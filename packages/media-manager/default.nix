{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "media-manager";
  version = "1.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "maxdorninger";
    repo = "MediaManager";
    rev = "v${version}";
    hash = "sha256-jAgWDS6OFGISFZhba3DXPA1UU+ovea4tNa5ypjvn+Uo=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    alembic
    apscheduler
    bencoder
    cachetools
    fastapi
    fastapi-restful
    fastapi-users
    fastapi-utils
    httpx
    httpx-oauth
    jsonschema
    patool
    pillow
    pillow-avif-plugin
    psycopg
    pydantic
    pydantic-settings
    pytest
    python-json-logger
    qbittorrent-api
    requests
    sqlalchemy
    starlette
    tmdbsimple
    tvdb-v4-official
    typing-inspect
    uvicorn
  ];

  pythonImportsCheck = [
    "mediamanager"
  ];

  meta = {
    description = "A modern selfhosted media management system for your media library";
    homepage = "https://github.com/maxdorninger/MediaManager";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ PopeRigby ];
    mainProgram = "media-manager";
  };
}
