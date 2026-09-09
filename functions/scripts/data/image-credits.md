# Image credits — articles and recipes

Provenance for every photo used by the `articles` and `recipes` catalogues. All of
them are re-hosted on Firebase Storage (`articles/{id}.jpeg`, `recipes/{id}.jpeg`,
and `-b{n}` for in-body extras) by `scripts/rehost-content-images.ts`; the original
source URL for each is the key in `scripts/data/image-url-map.json`.

Filenames in the authoring folder match the `id` in the corresponding Markdown
front matter, which is also the Firestore document id.

## Creative Commons — attribution required if published

| File | Source | Author | Licence |
|---|---|---|---|
| `tuna-oat-crunch-biscuits.jpg` | [Flickr](https://www.flickr.com/photos/155164036@N06/37369909885) | Monika Animallama | [CC BY 2.0](https://creativecommons.org/licenses/by/2.0/) |

The same photographer's second shot is used inline in that recipe:
[DIY Cat Treats](https://www.flickr.com/photos/155164036@N06/36557351423), CC BY 2.0.

## Unsplash Licence — free for commercial use, no attribution required

Every other photo comes from Unsplash. The exact source URL for each is a key in
`scripts/data/image-url-map.json`, which maps it to the Storage object we serve.

Attribution is not required by the Unsplash Licence but is appreciated by the
photographers.

## Verification

Every URL was checked for an HTTP 200 response, and a sample was opened and
inspected to confirm the subject matter. A 200 alone is not proof: during
selection, candidate URLs that returned 200 turned out to show a hamster, two
dogs, guinea pigs and a pizza. Those were discarded.
