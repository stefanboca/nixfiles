{
  fish,
  lib,
  writeTextFile,
}:

let
  name = "bencher";
in
writeTextFile {
  inherit name;
  executable = true;
  destination = "/bin/${name}";
  text = # fish
    ''
      #!${lib.getExe fish}
      # bencher
      # Single-invocation benchmark script:
      #   bencher <global-cpu-range> <bench-cpu-range> -- <cmd> [args...]
      #
      # Steps:
      # 1) Isolate <global-cpu-range> globally (init.scope, system.slice, user.slice)
      # 2) Run <cmd> in a transient "bench.slice" limited to <bench-cpu-range>
      # 3) Restore (clear) AllowedCPUs on all affected slices

      function print_usage
          echo "bencher"
          echo "Single-invocation benchmark script"
          echo
          echo "Usage:"
          echo "  $argv[1] <global-cpu-range> <bench-cpu-range> -- <cmd> [args...]"
          echo "Example:"
          echo "  Run a benchmark on cores 10-11"
          echo "  $argv[1] 0-9,12-19 10-11 -- cargo bench"
      end

      function isolate_global
          set global_range $argv[1]
          for scope in init.scope system.slice user.slice
              echo "[isolate] $scope -> AllowedCPUs=$global_range"
              sudo systemctl set-property --runtime $scope AllowedCPUs=$global_range
          end
      end

      function run_bench_slice
          set bench_range $argv[2]
          set slice_name "bench.slice"
          echo "[bench] creating slice $slice_name -> AllowedCPUs=$bench_range"
          sudo systemctl set-property --runtime $slice_name AllowedCPUs=$bench_range

          if test "$argv[3]" != --
              echo "[error] expected '--' before command"
              exit 1
          end
          set cmd $argv[4]
          set args $argv[5..-1]

          echo "[bench] launching '$cmd $args' in $slice_name"
          sudo systemd-inhibit systemd-run --uid=(id -u) --gid=(id -g) --unit=bench-job --slice=$slice_name --scope $cmd $args
      end

      function restore_all
          set total (nproc --all)
          set last (math $total - 1)
          set full_range "0-$last"

          for scope in init.scope system.slice user.slice bench.slice
              echo "[restore] $scope -> AllowedCPUs=$full_range"
              sudo systemctl set-property --runtime $scope AllowedCPUs=$full_range
          end
      end

      if test (count $argv) -lt 5
          print_usage (status current-command)
          exit 1
      end

      isolate_global $argv[1]
      run_bench_slice $argv[1] $argv[2] $argv[3] $argv[4] $argv[5..-1]
      restore_all

      echo "Benchmark complete. Restored all slices."
    '';
}
