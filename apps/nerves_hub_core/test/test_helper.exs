Logger.remove_backend(:console)
Code.compiler_options(ignore_module_conflict: true)

ExUnit.start()
