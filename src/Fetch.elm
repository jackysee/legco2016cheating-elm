module Fetch exposing (fetch)

import Models exposing (..)
import Http
import Task
import Json.Decode as Json exposing ( (:=) )

fetch: RegionName -> (Http.Error -> a) -> (Region -> a) -> Cmd a
fetch region failMsg successMsg =
    getUrl region
        |> Http.get (decode region)
        |> Task.perform failMsg successMsg


getUrl: RegionName -> String
getUrl region =
    case region of
        NTE -> "data/nte.json"
        NTW -> "data/ntw.json"
        KWE -> "data/kwe.json"
        KWW -> "data/kww.json"
        HK -> "data/hk.json"


decode: RegionName -> Json.Decoder Region
decode region =
    Json.object4 Region
        ("centers" := Json.list decodeCenter)
        ("candidates" := Json.list decodeCandidate)
        ("seats" := Json.int)
        (Json.succeed region)



decodeCenter: Json.Decoder Center
decodeCenter =
    Json.object4 Center
        ("code" := Json.string)
        ("cname" := Json.string)
        (Json.succeed True)
        ("votes" := decodeVotes)


decodeVotes: Json.Decoder (List (String, Int))
decodeVotes =
    Json.keyValuePairs Json.int


decodeCandidate: Json.Decoder Candidate
decodeCandidate =
    Json.object5 Candidate
        ("cand" := Json.int)
        ("name1" := Json.string)
        ("numcand" := Json.int)
        (Json.succeed 0) --votes
        (Json.succeed 0) --seat
