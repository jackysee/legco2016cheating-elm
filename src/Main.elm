import Models exposing (..)
import Msg exposing (..)
import Fetch
import View exposing (view)
import Html.App

fetch': RegionName -> Cmd Msg
fetch' regionName =
    Fetch.fetch regionName FetchFail FetchSuccess

-- init
init: (Model, Cmd Msg)
init = (
    { region =
        { centers = []
        , candidates = []
        , seat = 0
        , name = NTE
        }
    , fetchError = ""
    }
    , fetch' NTE
    )


-- Update
update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        FetchSuccess region ->
            ( { model | region = region, fetchError = "" } , Cmd.none )

        FetchFail error ->
            let
                error' =  Debug.log "Cannot fetch region data" error
            in
                ( { model | fetchError = "Cannot fetch region data!" }, Cmd.none )

        SetRegion regionName ->
            ( model, fetch' regionName )

        ToggleCenter code ->
            let
                region'  = model.region
                centers' = region'.centers
                    |> List.map (\center ->
                        if center.code == code then
                            {center | selected = not center.selected}
                        else
                            center
                    )
                model' = { model | region = { region' | centers = centers' } }
            in
                (model' , Cmd.none )


-- subscriptions
subscriptions: Model -> Sub Msg
subscriptions model = Sub.none


-- Main
main: Program Never
main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }




