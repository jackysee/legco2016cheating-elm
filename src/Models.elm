module Models exposing (..)

-- Model
type alias Center =
    { code: String
    , cname: String
    , selected: Bool
    , votes: List ( String, Int ) }

type alias Candidate =
    { id: Int
    , name: String
    , numcand: Int
    , votes: Int
    , seat: Int
    }

type RegionName = NTE | NTW | KWE | KWW | HK

type alias Region =
    { centers: List Center
    , candidates: List Candidate
    , seat: Int
    , name: RegionName
    }

type alias Model =
    { region: Region
    , fetchError : String
    }

