rule("linknan.emu")
  add_deps("c++")
  set_extensions(".v", ".sv")

  on_load(function (target)
    target:set("values", "verilator.compdir", "sim/emu/comp")

    local difftest = path.join("dependencies", "difftest")
    local difftest_vsrc = path.join(difftest, "src", "test", "vsrc")
    local difftest_vsrc_common = path.join(difftest_vsrc, "common")
    local difftest_csrc = path.join(difftest, "src", "test", "csrc")
    local difftest_csrc_common = path.join(difftest_csrc, "common")
    local difftest_csrc_difftest = path.join(difftest_csrc, "difftest")
    local difftest_csrc_spikedasm = path.join(difftest_csrc, "plugin", "spikedasm")
    local difftest_csrc_verilator = path.join(difftest_csrc, "verilator")

    target:add("includedirs", "dependencies/difftest/config")
    target:add("files", paht.join(difftest_vsrc_common, "*.sv"))

    target:add("includedirs", difftest_csrc_common)
    target:add("files", paht.join(difftest_csrc_common, "*.cpp"))

    target:add("includedirs", difftest_csrc_difftest)
    target:add("files", paht.join(difftest_csrc_difftest, "*.cpp"))

    target:add("includedirs", difftest_csrc_spikedasm)
    target:add("files", paht.join(difftest_csrc_spikedasm, "*.cpp"))

    target:add("includedirs", difftest_csrc_verilator)
    target:add("files", paht.join(difftest_csrc_verilator, "*.cpp"))

    target:set("kind", "binary")
    target:add("values", "verilator.flags", "-O3", "--stats-vars", "-Wno-UNOPTTHREADS", "-Wno-STMTDLY")
    target:add("values", "verilator.flags", "-Wno-WIDTH", "--assert", "--x-assign", "unique")
    target:add("values", "verilator.flags", "--output-split", "30000", "--output-split-cfuncs", "30001")
    target:add("values", "verilator.flags", "+define+PRINTF_COND=1", "+define+DIFFTEST", "--no-timing")
    target:add("defines", "VERILATOR")
    target:add("links", "dl")
  end)

  on_config(function (target)
    import("verilator").config(target)
  end)

  before_build_files(function (target, sourcebatch)
    -- Just to avoid before_buildcmd_files being executed at build time
  end)

  on_build_files(function (target, batchjobs, sourcebatch, opt)
    import("verilator").build_cppfiles(target, batchjobs, sourcebatch, opt)
  end, {batch = true, distcc = true})


