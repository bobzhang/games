///|
using @html {
  div, h1, h2, h3, p, span, a, button, input, section, nav, header, footer
}

///|
struct Model {
  search : String
  category : String
}

///|
enum Msg {
  SearchChanged(String)
  CategoryChanged(String)
}

///|
fn init_model() -> Model {
  { search: "", category: "all" }
}

///|
fn update(msg : Msg, model : Model) -> Model {
  match msg {
    SearchChanged(s) => { ..model, search: s }
    CategoryChanged(c) => { ..model, category: c }
  }
}

///|
fn view(dispatch : @rabbita.Dispatch[Msg], model : Model) -> @rabbita.Html {
  // Always show main view - games open in new tab via direct navigation
  main_view(dispatch, model)
}

///|
fn main_view(
  dispatch : @rabbita.Dispatch[Msg],
  model : Model
) -> @rabbita.Html {
  let is_searching = model.search != ""
  let is_filtered = model.category != "all"
  div(
    class="app",
    [
      render_header(dispatch, model),
      // Hide hero and featured when searching or filtering
      if is_searching || is_filtered {
        @html.nothing
      } else {
        render_hero()
      },
      if is_searching || is_filtered {
        @html.nothing
      } else {
        render_featured(dispatch)
      },
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
  let games = get_all_games()
  let featured : Array[GameInfo] = []
  for i in 0..<games.length() {
    if games[i].featured {
      featured.push(games[i])
    }
  }
  section(
    class="featured",
    [
      h2(class="section-title", "\u{2B50} Featured Games"),
      div(
        class="featured-grid",
        featured.map(fn(g) { featured_card(dispatch, g) }),
      ),
    ],
  )
}

///|
fn featured_card(
  _dispatch : @rabbita.Dispatch[Msg],
  game : GameInfo
) -> @rabbita.Html {
  a(
    class="featured-card",
    href="games/\{game.id}/\{game.id}.html",
    escape=true,
    [
      // Thumbnail with gradient + icon
      div(
        style=["background: \{genre_gradient(game.genre)}; height: 140px; border-radius: 10px 10px 0 0; display: flex; align-items: center; justify-content: center; position: relative; overflow: hidden;"],
        [
          span(
            style=["font-size: 48px; filter: drop-shadow(0 4px 8px rgba(0,0,0,0.4));"],
            game.icon,
          ),
          // Genre pill overlay
          span(
            style=["position: absolute; top: 10px; left: 10px; background: rgba(0,0,0,0.5); padding: 3px 10px; border-radius: 999px; font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px; color: \{genre_color(game.genre)};"],
            game.genre,
          ),
        ],
      ),
      // Card body
      div(
        style=["padding: 16px;"],
        [
          h3(class="featured-title", game.title),
          p(class="featured-desc", game.desc),
          button(class="play-btn", "\u{25B6}  Play Now"),
        ],
      ),
    ],
  )
}

///|
fn render_categories(
  dispatch : @rabbita.Dispatch[Msg],
  model : Model
) -> @rabbita.Html {
  let categories = [
    ("all", "\u{1F30D} All Games"),
    ("featured", "\u{2B50} Featured"),
    ("classic", "\u{1F579}\u{FE0F} Classic Ports"),
    ("3d", "\u{1F4A0} 3D Games"),
    ("2026", "\u{1F525} 2026 Collection"),
    ("raylib", "\u{1F4D6} Raylib Examples"),
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
      p(class="results-count", "\{games.length()} games"),
      div(class="game-grid", games.map(fn(g) { game_card(dispatch, g) })),
    ],
  )
}

///|
fn game_card(
  _dispatch : @rabbita.Dispatch[Msg],
  game : GameInfo
) -> @rabbita.Html {
  a(
    class="game-card",
    href="games/\{game.id}/\{game.id}.html",
    escape=true,
    [
      // Mini thumbnail with gradient + icon
      div(
        style=["background: \{genre_gradient(game.genre)}; height: 90px; border-radius: 8px 8px 0 0; display: flex; align-items: center; justify-content: center;"],
        [
          span(style=["font-size: 32px; opacity: 0.9;"], game.icon),
        ],
      ),
      // Card content
      div(
        style=["padding: 10px 12px;"],
        [
          div(
            style=["font-size: 10px; color: \{genre_color(game.genre)}; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px;"],
            game.genre,
          ),
          div(style=["font-size: 13px; font-weight: 600;"], game.title),
          if game.desc != "" {
            p(
              style=["font-size: 11px; color: #8899b0; margin-top: 4px; line-height: 1.4; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;"],
              game.desc,
            )
          } else {
            @html.nothing
          },
        ],
      ),
      // Play overlay hint
      div(class="card-play-overlay", [span(class="card-play-icon", "\u{25B6}")]),
    ],
  )
}


///|
fn render_footer() -> @rabbita.Html {
  footer(
    class="site-footer",
    [
      div(
        class="footer-inner",
        [
          p(
            class="footer-tech",
            [
              span("Powered by "),
              a(href="https://www.moonbitlang.com", target=Blank, "MoonBit"),
              span(" \u{00B7} "),
              a(href="https://www.raylib.com", target=Blank, "Raylib"),
              span(" \u{00B7} "),
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
                "\u{2B50} Star on GitHub",
              ),
              span(" \u{00B7} "),
              a(
                href="https://mooncakes.io/docs/#/bobzhang/games/",
                target=Blank,
                "MoonCakes Package",
              ),
            ],
          ),
        ],
      ),
    ],
  )
}


///|
fn get_filtered_games(model : Model) -> Array[GameInfo] {
  let all = get_all_games()
  let filtered : Array[GameInfo] = []
  for i in 0..<all.length() {
    let g = all[i]
    let cat_match = match model.category {
      "all" => true
      "featured" => g.featured
      "classic" =>
        g.id.contains("1983") ||
        g.id.contains("1985") ||
        g.id.contains("1987") ||
        g.id.contains("1988") ||
        g.id.contains("1990") ||
        g.id == "2048" ||
        g.id == "mario" ||
        g.id == "minesweeper"
      "3d" =>
        g.id.contains("_3d") ||
        g.id.contains("models_") ||
        g.id.contains("shaders_")
      "2026" => g.id.contains("_2026")
      "raylib" =>
        g.id.contains("core_") ||
        g.id.contains("shapes_") ||
        g.id.contains("textures_") ||
        g.id.contains("text_") ||
        g.id.contains("audio_")
      _ => true
    }
    let search_match = if model.search == "" {
      true
    } else {
      let s = model.search.to_lower()
      g.id.to_lower().contains(s) ||
      g.title.to_lower().contains(s) ||
      g.genre.to_lower().contains(s) ||
      g.desc.to_lower().contains(s)
    }
    if cat_match && search_match {
      filtered.push(g)
    }
  }
  filtered
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
