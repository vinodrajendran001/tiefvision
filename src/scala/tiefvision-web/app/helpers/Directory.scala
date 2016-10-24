package helpers

import java.io.{ File => JFile }
import java.nio.file.{ Files => JFiles, Paths }

object Directory {
  def getOrElseCreate(str: String): JFile = {
    val path = Paths.get(str)
    JFiles.createDirectories(path).toFile
  }
}
