{
  description = "Airflow development environment for NixOS";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            python312
            python312Packages.pip
            python312Packages.virtualenv
            # C/C++ 
            gcc
            glibc
            stdenv.cc.cc.lib
            # extra
            zlib
            libffi
            openssl
            uv
          ];
          
          shellHook = ''
            # 라이브러리 경로 설정
            export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.glibc}/lib:$LD_LIBRARY_PATH"
            exec zsh
            
            # Python 가상환경 자동 설정
            #if [ ! -d ".venv" ]; then
            #  python -m venv .venv
            #  echo "새 가상환경을 생성했습니다"
            #fi
            
            #echo "Airflow 개발 환경이 준비되었습니다"
            #source ./activate_venv.sh
            #echo "test"
          '';
        };
      });
}
