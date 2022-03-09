sub live_check {
  if (req.url == "/live") {
    return (synth(200));
  }
}