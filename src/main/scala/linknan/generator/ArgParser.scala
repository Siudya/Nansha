package linknan.generator

import org.chipsalliance.cde.config.Parameters
import xs.utils.perf.DebugOptionsKey
import zhujiang.ZJParametersKey

import scala.annotation.tailrec

object ArgParser {
  def apply(args: Array[String]): (Parameters, Array[String]) = {
    val configParam = args.filter(_ == "--config")

    val configuration = if(configParam.isEmpty) {
      println("Config is not assigned, use Full Configuration!")
      new FullConfig
    } else {
      val pos = args.indexOf(configParam.head)
      val cfgStr = args(pos + 1)
      val res = cfgStr match {
        case "reduced" => new ReducedConfig
        case "minimal" => new MinimalConfig
        case _ => new FullConfig
      }
      res
    }

    var firrtlOpts = Array[String]()
    var hasHelp: Boolean = false

    @tailrec
    def parse(config: Parameters, args: List[String]): Parameters = {
      args match {
        case Nil => config

        case "--help" :: tail =>
          hasHelp = true
          parse(config, tail)

        case "--fpga-platform" :: tail =>
          parse(config.alter((site, here, up) => {
            case DebugOptionsKey => up(DebugOptionsKey).copy(FPGAPlatform = true)
          }), tail)

        case "--enable-difftest" :: tail =>
          parse(config.alter((site, here, up) => {
            case DebugOptionsKey => up(DebugOptionsKey).copy(EnableDifftest = true)
          }), tail)

        case "--basic-difftest" :: tail =>
          parse(config.alter((site, here, up) => {
            case DebugOptionsKey => up(DebugOptionsKey).copy(AlwaysBasicDiff = true)
          }), tail)

        case "--prefix" :: confString :: tail =>
          parse(config.alter((site, here, up) => {
            case PrefixKey => confString
          }), tail)

        case option :: tail =>
          firrtlOpts :+= option
          parse(config, tail)
      }
    }

    val cfg = parse(configuration, args.toList)
    if(hasHelp) firrtlOpts :+= "--help"
    (cfg, firrtlOpts)
  }
}
