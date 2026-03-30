///|
using @html {
  div, h1, h2, h3, p, span, a, button, input, section, nav, header, footer
}

///|
struct Model {
  search : String
  category : String
  selected_game : String?
  show_controls : Bool
}

///|
enum Msg {
  SearchChanged(String)
  CategoryChanged(String)
  PlayGame(String)
  CloseGame
  ToggleControls
}

///|
fn init_model() -> Model {
  { search: "", category: "all", selected_game: None, show_controls: false }
}

///|
fn update(msg : Msg, model : Model) -> Model {
  match msg {
    SearchChanged(s) => { ..model, search: s }
    CategoryChanged(c) => { ..model, category: c }
    PlayGame(id) => { ..model, selected_game: Some(id) }
    CloseGame => { ..model, selected_game: None }
    ToggleControls => { ..model, show_controls: !model.show_controls }
  }
}

///|
fn view(dispatch : @rabbita.Dispatch[Msg], model : Model) -> @rabbita.Html {
  match model.selected_game {
    Some(game_id) => game_player_view(dispatch, game_id, model)
    None => main_view(dispatch, model)
  }
}

///|
fn main_view(
  dispatch : @rabbita.Dispatch[Msg],
  model : Model
) -> @rabbita.Html {
  div(
    class="app",
    [
      render_header(dispatch, model),
      render_hero(),
      render_featured(dispatch),
      render_categories(dispatch, model),
      render_game_grid(dispatch, model),
      render_footer(),
    ],
  )
}

///|
fn render_header(
  dispatch : @rabbita.Dispatch[Msg],
  model : Model
) -> @rabbita.Html {
  header(
    class="site-header",
    [
      div(
        class="header-inner",
        [
          div(
            class="logo",
            [
              span(class="logo-icon", "\u{1F3AE}"),
              h1(class="logo-text", "MoonBit Games"),
            ],
          ),
          div(
            class="search-bar",
            [
              input(
                class="search-input",
                input_type=Text,
                placeholder="Search 333 games...",
                value=model.search,
                on_input=fn(s) { dispatch(SearchChanged(s)) },
                "",
              ),
            ],
          ),
          nav(
            class="header-nav",
            [
              a(
                class="nav-link",
                href="https://github.com/bobzhang/games",
                target=Blank,
                "GitHub",
              ),
              a(
                class="nav-link",
                href="https://mooncakes.io/docs/#/bobzhang/games/",
                target=Blank,
                "MoonCakes",
              ),
            ],
          ),
        ],
      ),
    ],
  )
}

///|
fn render_hero() -> @rabbita.Html {
  section(
    class="hero",
    [
      div(
        class="hero-content",
        [
          h2(class="hero-title", "333 Games Built with MoonBit + Raylib"),
          p(
            class="hero-subtitle",
            "From classic arcade ports to 3D adventures \u{2014} all running in your browser via WebAssembly",
          ),
          div(
            class="hero-stats",
            [
              div(
                class="stat",
                [
                  span(class="stat-number", "333"),
                  span(class="stat-label", "Games"),
                ],
              ),
              div(
                class="stat",
                [
                  span(class="stat-number", "10"),
                  span(class="stat-label", "Genres"),
                ],
              ),
              div(
                class="stat",
                [
                  span(class="stat-number", "80K+"),
                  span(class="stat-label", "Lines of Code"),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  )
}

///|
fn render_featured(dispatch : @rabbita.Dispatch[Msg]) -> @rabbita.Html {
  section(
    class="featured",
    [
      h2(class="section-title", "Featured Games"),
      div(
        class="featured-grid",
        [
          featured_card(
            dispatch,
            "abyssal_rift",
            "Abyssal Rift",
            "Top-down roguelite dungeon crawler with 12 synergies, 2 bosses, meta-progression",
            "roguelite",
          ),
          featured_card(
            dispatch,
            "fighter_97_lite",
            "Fighter '97 Lite",
            "2D fighting game with 6 characters, motion-input specials, AI difficulty scaling",
            "fighting",
          ),
          featured_card(
            dispatch,
            "kart_racing_3d",
            "Kart Racing 3D",
            "Arcade kart racer with 8 racers, drift boost, 16 tracks across 4 cups",
            "racing",
          ),
          featured_card(
            dispatch,
            "tower_defense_3d",
            "Tower Defense 3D",
            "Strategic TD with 8 tower types, synergies, upgrades, 6 maps",
            "strategy",
          ),
          featured_card(
            dispatch,
            "space_combat_3d",
            "Space Combat 3D",
            "6DOF space combat with 12 missions, dogfighting AI, formation flying",
            "action",
          ),
          featured_card(
            dispatch,
            "naval_combat_3d",
            "Naval Combat 3D",
            "Wind-based sailing with broadside cannons and tactical fleet combat",
            "simulation",
          ),
        ],
      ),
    ],
  )
}

///|
fn featured_card(
  dispatch : @rabbita.Dispatch[Msg],
  id : String,
  title : String,
  desc : String,
  genre : String
) -> @rabbita.Html {
  div(
    class="featured-card",
    on_click=dispatch(PlayGame(id)),
    [
      div(class="featured-genre", genre),
      h3(class="featured-title", title),
      p(class="featured-desc", desc),
      button(class="play-btn", "Play Now"),
    ],
  )
}

///|
fn render_categories(
  dispatch : @rabbita.Dispatch[Msg],
  model : Model
) -> @rabbita.Html {
  let categories = [
    ("all", "All Games"),
    ("classic", "Classic Ports"),
    ("3d", "3D Games"),
    ("2026", "2026 Collection"),
    ("raylib", "Raylib Examples"),
  ]
  section(
    class="categories",
    [
      div(
        class="category-tabs",
        categories.map(
          fn(cat) {
            let (id, label) = cat
            let cls = if model.category == id {
              "cat-tab active"
            } else {
              "cat-tab"
            }
            button(class=cls, on_click=dispatch(CategoryChanged(id)), label)
          },
        ),
      ),
    ],
  )
}

///|
fn render_game_grid(
  dispatch : @rabbita.Dispatch[Msg],
  model : Model
) -> @rabbita.Html {
  let games = get_filtered_games(model)
  section(
    class="game-grid-section",
    [
      p(
        class="results-count",
        "\{games.length()} games",
      ),
      div(class="game-grid", games.map(fn(g) { game_card(dispatch, g) })),
    ],
  )
}

///|
fn game_card(
  dispatch : @rabbita.Dispatch[Msg],
  game : (String, String, String)
) -> @rabbita.Html {
  let (id, title, genre) = game
  div(
    class="game-card",
    on_click=dispatch(PlayGame(id)),
    [
      div(class="card-genre-badge", genre),
      div(class="card-title", title),
      div(class="card-play", "\u{25B6}"),
    ],
  )
}

///|
fn game_player_view(
  dispatch : @rabbita.Dispatch[Msg],
  game_id : String,
  model : Model
) -> @rabbita.Html {
  div(
    class="player-overlay",
    [
      div(
        class="player-header",
        [
          button(
            class="back-btn",
            on_click=dispatch(CloseGame),
            "\u{2190} Back to Games",
          ),
          span(class="playing-title", format_title(game_id)),
          button(
            class="controls-btn",
            on_click=dispatch(ToggleControls),
            "Controls",
          ),
        ],
      ),
      if model.show_controls {
        div(
          class="controls-panel",
          [
            p("Arrow Keys / WASD: Move"),
            p("Space / Enter: Action"),
            p("Shift: Run / Fire"),
            p("Escape: Pause / Menu"),
            p("1-6: Select weapon/item"),
          ],
        )
      } else {
        @html.nothing
      },
      @html.iframe(
        class="game-frame",
        src="games/\{game_id}/\{game_id}.html",
      ),
    ],
  )
}

///|
fn render_footer() -> @rabbita.Html {
  footer(
    class="site-footer",
    [
      p(
        [
          span("Built with "),
          a(href="https://www.moonbitlang.com", target=Blank, "MoonBit"),
          span(" + "),
          a(href="https://www.raylib.com", target=Blank, "Raylib"),
          span(" + "),
          a(
            href="https://github.com/moonbit-community/rabbita",
            target=Blank,
            "Rabbita",
          ),
        ],
      ),
      p(
        class="footer-links",
        [
          a(
            href="https://github.com/bobzhang/games",
            target=Blank,
            "Source Code",
          ),
          span(" \u{00B7} "),
          a(
            href="https://mooncakes.io/docs/#/bobzhang/games/",
            target=Blank,
            "Package",
          ),
        ],
      ),
    ],
  )
}

///|
fn format_title(id : String) -> String {
  // Convert snake_case to Title Case
  let mut result = ""
  let mut capitalize_next = true
  for c in id {
    if c == '_' {
      result = result + " "
      capitalize_next = true
    } else if capitalize_next {
      result = result + c.to_string().to_upper()
      capitalize_next = false
    } else {
      result = result + c.to_string()
    }
  }
  result
}

///|
fn get_filtered_games(model : Model) -> Array[(String, String, String)] {
  let all = get_all_games()
  let filtered : Array[(String, String, String)] = []
  for i in 0..<all.length() {
    let (id, title, genre) = all[i]
    // Category filter
    let cat_match = match model.category {
      "all" => true
      "classic" =>
        id.contains("1983") ||
        id.contains("1985") ||
        id.contains("1987") ||
        id.contains("1988") ||
        id.contains("1990") ||
        id == "2048" ||
        id == "mario" ||
        id == "minesweeper"
      "3d" =>
        id.contains("_3d") ||
        id.contains("models_") ||
        id.contains("shaders_")
      "2026" => id.contains("_2026")
      "raylib" =>
        id.contains("core_") ||
        id.contains("shapes_") ||
        id.contains("textures_") ||
        id.contains("text_") ||
        id.contains("audio_")
      _ => true
    }
    // Search filter
    let search_match = if model.search == "" {
      true
    } else {
      let lower_search = model.search.to_lower()
      id.to_lower().contains(lower_search) ||
      title.to_lower().contains(lower_search) ||
      genre.to_lower().contains(lower_search)
    }
    if cat_match && search_match {
      filtered.push((id, title, genre))
    }
  }
  filtered
}

///|
fn get_all_games() -> Array[(String, String, String)] {
  // Featured / quality-improved games first, then alphabetical
  [
    ("abyssal_rift", "Abyssal Rift", "roguelite"),
    ("fighter_97_lite", "Fighter '97 Lite", "fighting"),
    ("kart_racing_3d", "Kart Racing 3D", "racing"),
    ("tower_defense_3d", "Tower Defense 3D", "strategy"),
    ("space_combat_3d", "Space Combat 3D", "action"),
    ("naval_combat_3d", "Naval Combat 3D", "simulation"),
    ("dungeon_crawler_3d", "Dungeon Crawler 3D", "rpg"),
    ("survival_arena_3d", "Survival Arena 3D", "shooter"),
    ("bomberman_1983_lite", "Bomberman 1983 Lite", "classic"),
    ("tank_1990", "Tank 1990", "classic"),
    ("mario", "Mario", "platformer"),
    ("2048", "2048", "puzzle"),
    ("minesweeper", "Minesweeper", "puzzle"),
    ("super_mario_1985_lite", "Super Mario 1985 Lite", "classic"),
    ("contra_1987_lite", "Contra 1987 Lite", "classic"),
    ("jackal_1988_lite", "Jackal 1988 Lite", "classic"),
    ("platformer_3d", "Platformer 3D", "platformer"),
    ("flight_sim_3d", "Flight Sim 3D", "simulation"),
    ("voxel_world_3d", "Voxel World 3D", "sandbox"),
    ("puzzle_dungeon_3d", "Puzzle Dungeon 3D", "puzzle"),
    ("demo", "Demo", "example"),
  ]
}

///|
fn main {
  let app = @rabbita.simple_cell(
    model=init_model(),
    update=fn(msg, model) { update(msg, model) },
    view=fn(dispatch, model) { view(dispatch, model) },
  )
  @rabbita.new(app).mount("app")
}
