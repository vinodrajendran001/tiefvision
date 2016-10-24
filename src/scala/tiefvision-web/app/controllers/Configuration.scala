package controllers

import play.api.Play

object Configuration {

  lazy val HomeFolder = sys.env("TIEFVISION_HOME")
  val CropSize = 224
  val NumSamples = 5
  val BoundingBoxesFolder = s"$HomeFolder/resources/bounding-boxes"
  val ScaledImagesFolder = s"$HomeFolder/resources/bounding-boxes/scaled-images"
  val CropImagesFolder = s"$HomeFolder/resources/bounding-boxes/crops"
  val BackgroundCropImagesFolder = s"$HomeFolder/resources/bounding-boxes/background-crops"
  val DbImagesFolder = s"$HomeFolder/resources/dresses-db/master"
  val UploadedImagesFolder = s"$HomeFolder/resources/dresses-db/uploaded/master"
  val scaleLevels = Seq(2, 3)
  val testPercentage = 0.05

}
