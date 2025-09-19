# Extract an expiration date from a variety of RDAP JSON structures
.
| (
    [
      .events[]? | select((.eventAction // "") | test("expiration|expiry"; "i")) | .eventDate,
      .eventEventDate? // support some registries with slightly different names
    ]
    + (
      .entities[]?.events[]? // some registries nest under entities
      | select((.eventAction // "") | test("expiration|expiry"; "i"))
      | .eventDate
    )
    + (
      .objects[]?.events[]? // verisign nests under objects
      | select((.eventAction // "") | test("expiration|expiry"; "i"))
      | .eventDate
    )
    + (
      .domain? // PIR structures data under a domain key
      | [
          .events[]? | select((.eventAction // "") | test("expiration|expiry"; "i")) | .eventDate,
          .entities[]?.events[]? | select((.eventAction // "") | test("expiration|expiry"; "i")) | .eventDate
        ]
      | add
    )
  )
  | map(select(type == "string" and . != ""))
  | first
) // empty
