enum ViewPhase {
  case loading
  case error(Error)
  case page(ViaplayResponse)
}
