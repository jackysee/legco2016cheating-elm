module Msg exposing (..)

import Http
import Models exposing (Region, RegionName)

type Msg
    = FetchSuccess Region
    | FetchFail Http.Error
    | SetRegion RegionName
    | ToggleCenter String
