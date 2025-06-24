{ config, pkgs, ... }:

{
  # 개발에 필요한 패키지들을 사용자 환경에 추가
  home.packages = with pkgs; [
    python312
    python312Packages.pip
    python312Packages.virtualenv
    # C++ 라이브러리 의존성들
    gcc-unwrapped.lib
    glibc
    stdenv.cc.cc.lib
    # 추가 라이브러리들 (Airflow가 종종 필요로 함)
    zlib
    libffi
    openssl
    postgresql  # 데이터베이스 클라이언트
  ];

  # 환경 변수를 사용자 세션에 영구적으로 설정
  home.sessionVariables = {
    # C++ 라이브러리 경로를 Python이 찾을 수 있도록 설정
    LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.glibc}/lib";
    # Airflow 관련 환경 변수들
    AIRFLOW_HOME = "${config.home.homeDirectory}/workspace/nixflow";
    # Python 가상환경이 시스템 라이브러리를 찾을 수 있도록
    PYTHONPATH = "";
  };

  # 쉘 별칭이나 함수를 정의해서 작업을 편리하게 만들기
  programs.bash.shellAliases = {
    airflow-dev = "cd ~/workspace/nixflow && source .venv/bin/activate";
    airflow-init = "cd ~/workspace/nixflow && python -m venv .venv && source .venv/bin/activate && pip install apache-airflow==2.9.3";
  };

  # 더 정교한 설정을 위한 쉘 초기화 스크립트
  programs.bash.initExtra = ''
    # Airflow 개발 환경을 위한 함수 정의
    setup_airflow() {
      local project_dir="$HOME/workspace/nixflow"
      
      # 프로젝트 디렉토리로 이동
      cd "$project_dir" || return 1
      
      # 가상환경이 없으면 생성
      if [[ ! -d ".venv" ]]; then
        echo "가상환경을 생성하고 있습니다..."
        python -m venv .venv
      fi
      
      # 가상환경 활성화
      source .venv/bin/activate
      
      # Airflow가 설치되어 있지 않으면 설치
      if ! pip show apache-airflow &>/dev/null; then
        echo "Airflow를 설치하고 있습니다..."
        pip install apache-airflow==2.9.3 \
          --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.9.3/constraints-3.12.txt"
      fi
      
      echo "Airflow 개발 환경이 준비되었습니다!"
    }
  '';
}
