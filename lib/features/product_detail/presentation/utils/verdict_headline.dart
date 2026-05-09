String verdictHeadlineFor(String ratingText) {
  switch (ratingText.toLowerCase()) {
    case 'excellent':
      return 'A great everyday pick';
    case 'good':
      return 'A solid everyday pick';
    case 'average':
      return 'A reasonable choice';
    case 'poor':
      return 'Best to skip this one';
    default:
      return ratingText;
  }
}
