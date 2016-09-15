module View exposing (view)
import Msg exposing (..)
import Models exposing (..)
import Html exposing (Html, div, text, button, label, input, span, a)
import Html.Attributes exposing (style, class, type', checked, href)
import Html.Events exposing (onClick)
import String

-- View
view: Model -> Html Msg
view model =
    let
       resultVisible = if String.isEmpty model.fetchError then "visible" else "hidden"
    in
    div [ class "main" ]
        [ div [ class "title" ]
            [ text "Legco2016 Cheating GO! (in Elm)"
            , div [ class "info" ]
                [ text "a reimplementation of "
                , a [ href "https://github.com/chainsawriot" ] [ text "chainsawriot " ]
                , text "'s "
                , a [ href "http://chainsawriot.github.io/legco2016cheating/" ] [ text "選舉舞弊模擬器" ]
                , text " in "
                , a [ href "http://elm-lang.org" ] [ text "Elm "]
                ]
            ]
        , div [ class "error" ]  [ text model.fetchError ]
        , div [ class "content", style  [("visibility", resultVisible)] ]
            [ div [ class "buttons"  ]
                [ regionButton model NTE "新界東"
                , regionButton model NTW "新界西"
                , regionButton model KWE "九龍東"
                , regionButton model KWW "九龍西"
                , regionButton model HK "香港島"
                ]
            , div [ class "results" ]
                [ renderCenters model.region
                , renderResult model
                ]
            ]
        ]


renderError: Model -> Html Msg
renderError model =
    if String.isEmpty model.fetchError then
        div [] []
    else
        div [style [("color", "red")]] [text model.fetchError]


regionButton : Model -> RegionName -> String -> Html Msg
regionButton model regionName label =
    button
    [ class <| (if model.region.name == regionName then "is-active" else "")
    , onClick <| SetRegion regionName
    ]
    [ text label ]


renderCenters: Region -> Html Msg
renderCenters region =
    div [ class "centers" ] <| List.map (\center ->
        div []
        [ label []
            [input
                [ type' "checkbox"
                , onClick <| ToggleCenter center.code
                , checked center.selected
                ] []
            , text center.cname
            ]
        ]
    ) region.centers


renderResult: Model -> Html Msg
renderResult model =
    let
        seats = model.region.seat
        criteria = getTotalVotes model.region.centers // seats
    in
        div [ class "result" ]
            (model.region.candidates
                |> List.map (countVotes model.region.centers)
                |> takeSeat criteria seats
                |> List.map (\candidate ->
                    div [ class (if candidate.seat > 0 then "has-seat" else "") ]
                        [ span [ class "cand-id" ]
                            [ text <| toString candidate.id ++ "." ]
                        , span []
                            [ text
                                <| candidate.name
                                ++ " (" ++ toString candidate.seat ++ "席, "
                                ++ toString candidate.votes
                                ++ ")"
                            ]
                        ]
                )
            )


getTotalVotes: List Center -> Int
getTotalVotes centers =
    centers
        |> List.map (\center -> center.votes)
        |> List.concat
        |> List.map (\(name, votes) -> votes)
        |> List.sum


countVotes: List Center -> Candidate -> Candidate
countVotes centers candidate =
    { candidate
        | votes = centers
            |> List.filter (\center -> center.selected )
            |> List.map (getVotesByCenter candidate)
            |> List.sum
    }


getVotesByCenter: Candidate -> Center-> Int
getVotesByCenter candidate center =
    center.votes
        |> List.map (\(name, votes) -> if candidate.name == name then votes else  0 )
        |> List.sum


takeSeat: Int -> Int -> List Candidate -> List Candidate
takeSeat criteria seat candidates =
    let
        candidates' = countSeat criteria seat candidates
        seatLeft = candidates'
            |> List.map (\(candidate, votesLeft) -> candidate.seat )
            |> List.sum
            |> (-) seat
    in
        candidates'
            |> List.sortBy (\(candidate, votesLeft) -> -1 * votesLeft )
            |> countRemainSeat seatLeft
            |> List.sortBy .id



countSeat: Int -> Int -> List Candidate -> List (Candidate, Int)
countSeat criteria seat candidates =
    case candidates of
        [] -> []
        candidate :: rest ->
            let
                seatTaken = (candidate.votes // criteria)
                            |> min candidate.numcand
                            |> min seat
                seatLeft = seat - seatTaken
            in
                ( { candidate | seat = seatTaken }
                , candidate.votes - seatTaken * criteria
                )
                :: countSeat criteria seatLeft rest


countRemainSeat: Int -> List (Candidate, Int) -> List Candidate
countRemainSeat seat candidates =
    case candidates of
        [] -> []
        (candidate, votes) :: rest ->
            let
                canTake = if candidate.numcand > candidate.seat then 1 else 0
                seatTaken = min canTake seat
                seatLeft = seat - seatTaken
            in
                { candidate | seat = candidate.seat + seatTaken }
                :: countRemainSeat seatLeft rest


