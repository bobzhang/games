///|
pub fn get_all_cases() -> Array[@types.Case] {
  let cases : Array[@types.Case] = []
  // Tier 1: Reports (7 cases, 6 cards each)
  cases.push(case_01_warehouse_fire())
  cases.push(case_02_missing_shipment())
  cases.push(case_03_office_break_in())
  cases.push(case_04_food_poisoning())
  cases.push(case_05_traffic_accident())
  cases.push(case_06_power_outage())
  cases.push(case_07_museum_theft())
  // Tier 2: Investigations (7 cases, 7 cards each)
  cases.push(case_08_lab_incident())
  cases.push(case_09_stage_accident())
  cases.push(case_10_sabotage())
  cases.push(case_11_expedition_failure())
  cases.push(case_12_heist_gone_wrong())
  cases.push(case_13_data_breach())
  cases.push(case_14_train_delay())
  // Tier 3: Cold Cases (6 cases, 8 cards each)
  cases.push(case_15_political_coverup())
  cases.push(case_16_ship_sinking())
  cases.push(case_17_reactor_meltdown())
  cases.push(case_18_art_forgery())
  cases.push(case_19_double_agent())
  cases.push(case_20_vanishing_witness())
  cases
}

///|
pub fn get_case(tier : @types.Tier, index : Int) -> @types.Case {
  let cases = get_all_cases()
  let offset = match tier {
    Reports => 0
    Investigations => 7
    ColdCases => 14
  }
  cases[offset + index]
}

// ============================================================
// TIER 1: REPORTS (6 cards each, 1-2 cause links)
// ============================================================

///|
fn case_01_warehouse_fire() -> @types.Case {
  let c = @types.make_event_card
  let cards = [
    c(0, "Electrician", "rewires junction box", "morning", -1),
    c(1, "Manager", "disables fire alarm for test", "late morning", 0),
    c(2, "Sparks", "ignite oil rags near box", "noon", -1),
    c(3, "Worker", "notices smoke from storage", "after noon", -1),
    c(4, "Fire dept", "arrives at warehouse", "1 PM", -1),
    c(5, "Building", "declared total loss", "evening", 5),
  ]
  {
    cards,
    solution_order: [1, 0, 2, 3, 4, 5],
    solution_links: [@types.make_link(0, 2), @types.make_link(1, 2)],
    clues: [
      @types.make_clue(Before, 0, 2, "Rewiring happened before the sparks"),
      @types.make_clue(
        Because,
        1,
        2,
        "Disabled alarm allowed fire to spread unnoticed",
      ),
      @types.make_clue(After, 4, 3, "Fire dept came after smoke was noticed"),
    ],
    anchors: [1, 5],
    tier: Reports,
    title: "The Warehouse Fire",
    theme: "Arson investigation",
  }
}

///|
fn case_02_missing_shipment() -> @types.Case {
  let c = @types.make_event_card
  let cards = [
    c(0, "Driver", "picks up cargo at port", "6 AM", 0),
    c(1, "Dispatcher", "changes route via radio", "7 AM", -1),
    c(2, "Driver", "takes detour through alley", "7:30 AM", -1),
    c(3, "Truck", "found empty in parking lot", "9 AM", -1),
    c(4, "Camera", "shows two men unloading", "8 AM", -1),
    c(5, "Police", "file report on missing goods", "noon", 5),
  ]
  {
    cards,
    solution_order: [0, 1, 2, 4, 3, 5],
    solution_links: [@types.make_link(1, 2)],
    clues: [
      @types.make_clue(
        Because,
        1,
        2,
        "Route change caused driver to take detour",
      ),
      @types.make_clue(Before, 4, 3, "Unloading happened before truck found"),
      @types.make_clue(After, 2, 1, "Detour was after route change"),
    ],
    anchors: [0, 5],
    tier: Reports,
    title: "The Missing Shipment",
    theme: "Cargo theft",
  }
}

///|
fn case_03_office_break_in() -> @types.Case {
  let c = @types.make_event_card
  let cards = [
    c(0, "Janitor", "leaves back door unlocked", "10 PM", -1),
    c(1, "Security", "ends patrol early", "10:30 PM", 0),
    c(2, "Intruder", "enters via back door", "11 PM", -1),
    c(3, "Intruder", "copies files from server", "11:30 PM", -1),
    c(4, "Alarm", "triggers on exit", "midnight", -1),
    c(5, "Police", "arrive to find door open", "12:15 AM", 5),
  ]
  {
    cards,
    solution_order: [1, 0, 2, 3, 4, 5],
    solution_links: [@types.make_link(0, 2), @types.make_link(2, 3)],
    clues: [
      @types.make_clue(Because, 0, 2, "Unlocked door allowed intruder entry"),
      @types.make_clue(Before, 2, 3, "Entry came before copying files"),
      @types.make_clue(After, 4, 3, "Alarm triggered after file copy"),
    ],
    anchors: [1, 5],
    tier: Reports,
    title: "The Office Break-In",
    theme: "Corporate espionage",
  }
}

///|
fn case_04_food_poisoning() -> @types.Case {
  let c = @types.make_event_card
  let cards = [
    c(0, "Supplier", "delivers expired ingredients", "morning", 0),
    c(1, "Chef", "skips quality check", "late morning", -1),
    c(2, "Kitchen", "prepares lunch batch", "noon", -1),
    c(3, "Guests", "eat at banquet", "1 PM", -1),
    c(4, "First guest", "reports stomach pain", "3 PM", -1),
    c(5, "Health inspector", "shuts down kitchen", "evening", 5),
  ]
  {
    cards,
    solution_order: [0, 1, 2, 3, 4, 5],
    solution_links: [@types.make_link(0, 2), @types.make_link(1, 2)],
    clues: [
      @types.make_clue(Because, 0, 2, "Expired ingredients went into the lunch"),
      @types.make_clue(Because, 1, 2, "Skipped check let bad food through"),
      @types.make_clue(After, 4, 3, "Pain reported after eating"),
    ],
    anchors: [0, 5],
    tier: Reports,
    title: "The Banquet Illness",
    theme: "Food safety",
  }
}

///|
fn case_05_traffic_accident() -> @types.Case {
  let c = @types.make_event_card
  let cards = [
    c(0, "Road crew", "removes warning signs", "8 AM", 0),
    c(1, "Rain", "makes road slippery", "9 AM", -1),
    c(2, "Bus driver", "takes curve too fast", "9:30 AM", -1),
    c(3, "Bus", "slides into guardrail", "9:31 AM", -1),
    c(4, "Paramedics", "treat injured passengers", "10 AM", -1),
    c(5, "Investigation", "finds multiple causes", "afternoon", 5),
  ]
  {
    cards,
    solution_order: [0, 1, 2, 3, 4, 5],
    solution_links: [@types.make_link(1, 3)],
    clues: [
      @types.make_clue(Before, 1, 2, "Rain started before the bus passed"),
      @types.make_clue(Because, 1, 3, "Slippery road caused the slide"),
      @types.make_clue(After, 4, 3, "Paramedics came after the crash"),
    ],
    anchors: [0, 5],
    tier: Reports,
    title: "The Bus Crash",
    theme: "Traffic investigation",
  }
}

///|
fn case_06_power_outage() -> @types.Case {
  let c = @types.make_event_card
  let cards = [
    c(0, "Utility worker", "skips transformer check", "morning", -1),
    c(1, "Heatwave", "increases power demand", "afternoon", 1),
    c(2, "Transformer", "overheats", "3 PM", -1),
    c(3, "Grid", "shuts down sector 7", "3:05 PM", -1),
    c(4, "Hospital", "switches to backup power", "3:10 PM", -1),
    c(5, "Power", "restored after 4 hours", "7 PM", 5),
  ]
  {
    cards,
    solution_order: [0, 1, 2, 3, 4, 5],
    solution_links: [@types.make_link(2, 3)],
    clues: [
      @types.make_clue(
        Before,
        0,
        2,
        "Skipped check happened before overheating",
      ),
      @types.make_clue(Because, 2, 3, "Overheated transformer caused shutdown"),
      @types.make_clue(After, 4, 3, "Hospital switched after grid went down"),
    ],
    anchors: [1, 5],
    tier: Reports,
    title: "The Blackout",
    theme: "Infrastructure failure",
  }
}

///|
fn case_07_museum_theft() -> @types.Case {
  let c = @types.make_event_card
  let cards = [
    c(0, "Guard", "leaves post for break", "midnight", 0),
    c(1, "Camera", "feed loops for 10 min", "12:05 AM", -1),
    c(2, "Thief", "enters through skylight", "12:10 AM", -1),
    c(3, "Painting", "removed from frame", "12:15 AM", -1),
    c(4, "Alarm", "triggers on exit", "12:20 AM", -1),
    c(5, "Guard", "finds empty frame", "12:25 AM", 5),
  ]
  {
    cards,
    solution_order: [0, 1, 2, 3, 4, 5],
    solution_links: [@types.make_link(0, 2), @types.make_link(1, 2)],
    clues: [
      @types.make_clue(Because, 0, 2, "Guard leaving allowed skylight entry"),
      @types.make_clue(Because, 1, 2, "Looped camera hid the entry"),
      @types.make_clue(Before, 3, 4, "Painting taken before alarm"),
    ],
    anchors: [0, 5],
    tier: Reports,
    title: "The Museum Heist",
    theme: "Art theft",
  }
}

// ============================================================
// TIER 2: INVESTIGATIONS (7 cards each, 2-3 cause links)
// ============================================================

///|
fn case_08_lab_incident() -> @types.Case {
  let c = @types.make_event_card
  let cards = [
    c(0, "Researcher", "mislabels chemical batch", "Monday AM", -1),
    c(1, "Intern", "mixes wrong chemicals", "Monday PM", -1),
    c(2, "Fumes", "fill ventilation system", "Monday evening", -1),
    c(3, "Lab tech", "reports burning smell", "Monday night", 3),
    c(4, "Evacuation", "ordered for building", "Tuesday AM", -1),
    c(5, "Three staff", "hospitalized", "Tuesday PM", -1),
    c(6, "Lab", "shut down for review", "Wednesday", 6),
  ]
  {
    cards,
    solution_order: [0, 1, 2, 3, 4, 5, 6],
    solution_links: [
      @types.make_link(0, 1),
      @types.make_link(1, 2),
      @types.make_link(2, 5),
    ],
    clues: [
      @types.make_clue(Because, 0, 1, "Mislabeled batch caused wrong mix"),
      @types.make_clue(Because, 1, 2, "Wrong chemicals produced fumes"),
      @types.make_clue(Before, 3, 4, "Smell reported before evacuation"),
      @types.make_clue(Because, 2, 5, "Fumes caused hospitalizations"),
    ],
    anchors: [3, 6],
    tier: Investigations,
    title: "The Lab Incident",
    theme: "Chemical accident",
  }
}

///|
fn case_09_stage_accident() -> @types.Case {
  let c = @types.make_event_card
  let cards = [
    c(0, "Stagehand", "uses wrong bolt size", "setup day", -1),
    c(1, "Director", "adds extra lighting rig", "dress rehearsal", 1),
    c(2, "Weight", "exceeds beam limit", "opening night", -1),
    c(3, "Beam", "cracks during act two", "during show", -1),
    c(4, "Lighting rig", "crashes onto stage", "mid-show", -1),
    c(5, "Actor", "suffers broken arm", "immediately after", -1),
    c(6, "Theater", "cancels remaining shows", "next day", 6),
  ]
  {
    cards,
    solution_order: [0, 1, 2, 3, 4, 5, 6],
    solution_links: [
      @types.make_link(0, 3),
      @types.make_link(1, 2),
      @types.make_link(3, 4),
    ],
    clues: [
      @types.make_clue(Because, 0, 3, "Wrong bolt weakened the beam"),
      @types.make_clue(Because, 1, 2, "Extra rig added too much weight"),
      @types.make_clue(Because, 3, 4, "Cracked beam dropped the rig"),
      @types.make_clue(Before, 4, 5, "Rig fell before injury"),
    ],
    anchors: [1, 6],
    tier: Investigations,
    title: "The Stage Collapse",
    theme: "Theater accident",
  }
}

///|
fn case_10_sabotage() -> @types.Case {
  let c = @types.make_event_card
  let cards = [
    c(0, "Rival firm", "bribes maintenance tech", "week before", -1),
    c(1, "Tech", "loosens conveyor bolts", "night shift", -1),
    c(2, "Morning crew", "starts production line", "6 AM", 2),
    c(3, "Conveyor", "jams and overheats", "8 AM", -1),
    c(4, "Products", "ruined in pile-up", "8:05 AM", -1),
    c(5, "Factory", "misses critical deadline", "that evening", -1),
    c(6, "Client", "cancels contract", "next week", 6),
  ]
  {
    cards,
    solution_order: [0, 1, 2, 3, 4, 5, 6],
    solution_links: [
      @types.make_link(0, 1),
      @types.make_link(1, 3),
      @types.make_link(4, 5),
    ],
    clues: [
      @types.make_clue(Because, 0, 1, "Bribe motivated the sabotage"),
      @types.make_clue(Because, 1, 3, "Loose bolts caused the jam"),
      @types.make_clue(Because, 4, 5, "Ruined products missed the deadline"),
      @types.make_clue(Before, 0, 2, "Bribe happened before production"),
    ],
    anchors: [2, 6],
    tier: Investigations,
    title: "Industrial Sabotage",
    theme: "Corporate sabotage",
  }
}

///|
fn case_11_expedition_failure() -> @types.Case {
  let c = @types.make_event_card
  let cards = [
    c(0, "Sponsor", "cuts budget for supplies", "week before", 0),
    c(1, "Lead guide", "falls ill", "day before", -1),
    c(2, "Team", "sets out with backup guide", "day one", -1),
    c(3, "Storm", "hits mountain pass", "day two", -1),
    c(4, "Radio", "fails in cold", "day two night", -1),
    c(5, "Team", "takes wrong descent route", "day three", -1),
    c(6, "Rescue", "finds team after 48 hours", "day five", 6),
  ]
  {
    cards,
    solution_order: [0, 1, 2, 3, 4, 5, 6],
    solution_links: [@types.make_link(0, 4), @types.make_link(1, 5)],
    clues: [
      @types.make_clue(Because, 0, 4, "Budget cuts meant cheap radio equipment"),
      @types.make_clue(Because, 1, 5, "Backup guide chose wrong route"),
      @types.make_clue(Before, 3, 4, "Storm came before radio failure"),
      @types.make_clue(After, 5, 4, "Wrong route taken after radio died"),
    ],
    anchors: [0, 6],
    tier: Investigations,
    title: "The Lost Expedition",
    theme: "Mountain disaster",
  }
}

///|
fn case_12_heist_gone_wrong() -> @types.Case {
  let c = @types.make_event_card
  let cards = [
    c(0, "Mastermind", "recruits inside man", "two weeks before", -1),
    c(1, "Inside man", "copies vault codes", "one week before", 1),
    c(2, "Getaway driver", "scouts escape routes", "day before", -1),
    c(3, "Team", "enters bank at closing", "6 PM", -1),
    c(4, "Alarm", "silent trigger to police", "6:10 PM", -1),
    c(5, "Police", "surround building", "6:20 PM", -1),
    c(6, "Team", "arrested in vault", "6:30 PM", 6),
  ]
  {
    cards,
    solution_order: [0, 1, 2, 3, 4, 5, 6],
    solution_links: [
      @types.make_link(0, 1),
      @types.make_link(1, 3),
      @types.make_link(4, 5),
    ],
    clues: [
      @types.make_clue(Because, 0, 1, "Mastermind got inside man to copy codes"),
      @types.make_clue(Because, 1, 3, "Copied codes enabled bank entry"),
      @types.make_clue(Because, 4, 5, "Silent alarm brought police"),
      @types.make_clue(Before, 2, 3, "Routes scouted before the heist"),
    ],
    anchors: [1, 6],
    tier: Investigations,
    title: "The Bank Job",
    theme: "Heist gone wrong",
  }
}

///|
fn case_13_data_breach() -> @types.Case {
  let c = @types.make_event_card
  let cards = [
    c(0, "Employee", "clicks phishing email", "Monday morning", -1),
    c(1, "Malware", "installs on network", "Monday noon", -1),
    c(2, "Attacker", "gains admin access", "Monday evening", 2),
    c(3, "Database", "copied to external server", "Tuesday AM", -1),
    c(4, "IT team", "notices unusual traffic", "Tuesday PM", -1),
    c(5, "System", "taken offline for audit", "Wednesday", -1),
    c(6, "CEO", "announces data breach", "Thursday", 6),
  ]
  {
    cards,
    solution_order: [0, 1, 2, 3, 4, 5, 6],
    solution_links: [
      @types.make_link(0, 1),
      @types.make_link(1, 2),
      @types.make_link(2, 3),
    ],
    clues: [
      @types.make_clue(Because, 0, 1, "Phishing email installed malware"),
      @types.make_clue(Because, 1, 2, "Malware gave admin access"),
      @types.make_clue(Because, 2, 3, "Admin access enabled data copy"),
      @types.make_clue(Before, 4, 5, "Traffic noticed before shutdown"),
    ],
    anchors: [2, 6],
    tier: Investigations,
    title: "The Data Breach",
    theme: "Cybercrime",
  }
}

///|
fn case_14_train_delay() -> @types.Case {
  let c = @types.make_event_card
  let cards = [
    c(0, "Signal tech", "installs faulty relay", "night before", -1),
    c(1, "Freight train", "passes through junction", "5 AM", 1),
    c(2, "Signal", "stuck on red", "5:30 AM", -1),
    c(3, "Express", "halted before junction", "6 AM", -1),
    c(4, "Passengers", "miss connecting flights", "8 AM", -1),
    c(5, "Controller", "reroutes via branch line", "6:30 AM", -1),
    c(6, "Investigation", "finds relay fault", "afternoon", 6),
  ]
  {
    cards,
    solution_order: [0, 1, 2, 3, 5, 4, 6],
    solution_links: [@types.make_link(0, 2), @types.make_link(2, 3)],
    clues: [
      @types.make_clue(Because, 0, 2, "Faulty relay caused stuck signal"),
      @types.make_clue(Because, 2, 3, "Red signal halted the express"),
      @types.make_clue(Before, 5, 4, "Reroute attempted before flights missed"),
      @types.make_clue(After, 3, 1, "Express halted after freight passed"),
    ],
    anchors: [1, 6],
    tier: Investigations,
    title: "The Train Delay",
    theme: "Transit disruption",
  }
}

// ============================================================
// TIER 3: COLD CASES (8 cards each, 3-4 cause links)
// ============================================================

///|
fn case_15_political_coverup() -> @types.Case {
  let c = @types.make_event_card
  let cards = [
    c(0, "Journalist", "obtains leaked documents", "January", -1),
    c(1, "Official", "orders document shredding", "February", 1),
    c(2, "Whistleblower", "contacts journalist", "March", -1),
    c(3, "Editor", "publishes exposé", "April", -1),
    c(4, "Official", "denies allegations", "April", -1),
    c(5, "Witness", "testifies to committee", "May", -1),
    c(6, "Official", "resigns from post", "June", -1),
    c(7, "Court", "orders full investigation", "July", 7),
  ]
  {
    cards,
    solution_order: [0, 1, 2, 3, 4, 5, 6, 7],
    solution_links: [
      @types.make_link(0, 1),
      @types.make_link(2, 3),
      @types.make_link(3, 4),
      @types.make_link(5, 6),
    ],
    clues: [
      @types.make_clue(
        Because,
        0,
        1,
        "Leaked docs triggered the shredding order",
      ),
      @types.make_clue(Because, 2, 3, "Whistleblower enabled the exposé"),
      @types.make_clue(Because, 3, 4, "Exposé forced the denial"),
      @types.make_clue(Because, 5, 6, "Testimony led to resignation"),
      @types.make_clue(During, 3, 4, "Denial came same month as exposé"),
    ],
    anchors: [1, 7],
    tier: ColdCases,
    title: "The Cover-Up",
    theme: "Political scandal",
  }
}

///|
fn case_16_ship_sinking() -> @types.Case {
  let c = @types.make_event_card
  let cards = [
    c(0, "Inspector", "falsifies hull report", "week before", -1),
    c(1, "Captain", "overloads cargo hold", "departure day", 1),
    c(2, "Ship", "leaves port in storm", "evening", -1),
    c(3, "Hull plate", "buckles under stress", "night", -1),
    c(4, "Water", "floods engine room", "late night", -1),
    c(5, "Crew", "sends distress signal", "midnight", -1),
    c(6, "Rescue ships", "arrive at dawn", "next morning", -1),
    c(7, "Inquiry", "blames multiple failures", "weeks later", 7),
  ]
  {
    cards,
    solution_order: [0, 1, 2, 3, 4, 5, 6, 7],
    solution_links: [
      @types.make_link(0, 3),
      @types.make_link(1, 3),
      @types.make_link(3, 4),
    ],
    clues: [
      @types.make_clue(Because, 0, 3, "False report hid hull weakness"),
      @types.make_clue(Because, 1, 3, "Overloaded cargo stressed the hull"),
      @types.make_clue(Because, 3, 4, "Buckled plate let water in"),
      @types.make_clue(Before, 5, 6, "Distress signal before rescue"),
      @types.make_clue(NotAdjacent, 0, 5, "Report and signal far apart"),
    ],
    anchors: [1, 7],
    tier: ColdCases,
    title: "The Sinking",
    theme: "Maritime disaster",
  }
}

///|
fn case_17_reactor_meltdown() -> @types.Case {
  let c = @types.make_event_card
  let cards = [
    c(0, "Manager", "ignores safety audit", "month before", 0),
    c(1, "Sensor", "gives false reading", "night shift", -1),
    c(2, "Operator", "reduces coolant flow", "based on reading", -1),
    c(3, "Core temp", "rises beyond threshold", "2 AM", -1),
    c(4, "Backup system", "fails to activate", "2:15 AM", -1),
    c(5, "Partial meltdown", "begins", "2:30 AM", -1),
    c(6, "Emergency team", "floods reactor", "3 AM", -1),
    c(7, "Zone", "evacuated 30km radius", "dawn", 7),
  ]
  {
    cards,
    solution_order: [0, 1, 2, 3, 4, 5, 6, 7],
    solution_links: [
      @types.make_link(1, 2),
      @types.make_link(2, 3),
      @types.make_link(0, 4),
      @types.make_link(3, 5),
    ],
    clues: [
      @types.make_clue(Because, 1, 2, "False reading led to reduced coolant"),
      @types.make_clue(Because, 2, 3, "Low coolant caused temp rise"),
      @types.make_clue(Because, 0, 4, "Ignored audit left backup unmaintained"),
      @types.make_clue(Because, 3, 5, "High temp triggered meltdown"),
      @types.make_clue(Before, 5, 6, "Meltdown before emergency response"),
    ],
    anchors: [0, 7],
    tier: ColdCases,
    title: "The Meltdown",
    theme: "Nuclear disaster",
  }
}

///|
fn case_18_art_forgery() -> @types.Case {
  let c = @types.make_event_card
  let cards = [
    c(0, "Forger", "creates replica painting", "three months before", -1),
    c(1, "Dealer", "authenticates forgery", "two months before", 1),
    c(2, "Collector", "purchases painting", "auction day", -1),
    c(3, "Appraiser", "notices pigment anomaly", "two weeks later", -1),
    c(4, "Lab", "confirms modern materials", "one month later", -1),
    c(5, "Dealer", "flees the country", "same week", -1),
    c(6, "Interpol", "issues arrest warrant", "next month", -1),
    c(7, "Dealer", "arrested at border", "three months later", 7),
  ]
  {
    cards,
    solution_order: [0, 1, 2, 3, 4, 5, 6, 7],
    solution_links: [
      @types.make_link(0, 1),
      @types.make_link(1, 2),
      @types.make_link(3, 4),
      @types.make_link(4, 6),
    ],
    clues: [
      @types.make_clue(
        Because,
        0,
        1,
        "Forger supplied painting for authentication",
      ),
      @types.make_clue(Because, 1, 2, "Authentication enabled the sale"),
      @types.make_clue(Because, 3, 4, "Anomaly prompted lab testing"),
      @types.make_clue(Because, 4, 6, "Lab proof led to arrest warrant"),
      @types.make_clue(During, 4, 5, "Dealer fled as lab results came in"),
    ],
    anchors: [1, 7],
    tier: ColdCases,
    title: "The Forgery Ring",
    theme: "Art crime",
  }
}

///|
fn case_19_double_agent() -> @types.Case {
  let c = @types.make_event_card
  let cards = [
    c(0, "Agent", "recruited by foreign service", "year before", 0),
    c(1, "Agent", "passes classified intel", "six months before", -1),
    c(2, "Operation", "compromised overseas", "four months before", -1),
    c(3, "Analyst", "notices pattern in leaks", "two months before", -1),
    c(4, "Counter-intel", "sets trap with false info", "one month before", -1),
    c(5, "Agent", "passes false intel", "two weeks before", -1),
    c(6, "Foreign handler", "acts on false intel", "one week before", -1),
    c(7, "Agent", "arrested at dead drop", "present day", 7),
  ]
  {
    cards,
    solution_order: [0, 1, 2, 3, 4, 5, 6, 7],
    solution_links: [
      @types.make_link(0, 1),
      @types.make_link(1, 2),
      @types.make_link(3, 4),
      @types.make_link(5, 6),
    ],
    clues: [
      @types.make_clue(Because, 0, 1, "Recruitment led to intel passing"),
      @types.make_clue(Because, 1, 2, "Leaked intel compromised operation"),
      @types.make_clue(Because, 3, 4, "Pattern detection led to the trap"),
      @types.make_clue(Because, 5, 6, "False intel tricked the handler"),
      @types.make_clue(
        NotAdjacent,
        2,
        5,
        "Compromised op and false intel far apart",
      ),
    ],
    anchors: [0, 7],
    tier: ColdCases,
    title: "The Double Agent",
    theme: "Espionage",
  }
}

///|
fn case_20_vanishing_witness() -> @types.Case {
  let c = @types.make_event_card
  let cards = [
    c(0, "Witness", "sees crime from balcony", "Friday night", 0),
    c(1, "Witness", "reports to police", "Saturday morning", -1),
    c(2, "Detective", "schedules formal interview", "Saturday noon", -1),
    c(3, "Suspect", "learns of witness", "Saturday evening", -1),
    c(4, "Witness", "receives threatening call", "Saturday night", -1),
    c(5, "Witness", "disappears from home", "Sunday morning", -1),
    c(6, "Detective", "finds signs of forced entry", "Sunday noon", -1),
    c(7, "Case", "goes cold without testimony", "months later", 7),
  ]
  {
    cards,
    solution_order: [0, 1, 2, 3, 4, 5, 6, 7],
    solution_links: [
      @types.make_link(0, 1),
      @types.make_link(1, 3),
      @types.make_link(3, 4),
      @types.make_link(4, 5),
    ],
    clues: [
      @types.make_clue(Because, 0, 1, "Seeing crime prompted the report"),
      @types.make_clue(Because, 1, 3, "Report leaked to suspect"),
      @types.make_clue(Because, 3, 4, "Suspect threatened the witness"),
      @types.make_clue(Because, 4, 5, "Threats caused disappearance"),
      @types.make_clue(Before, 2, 3, "Interview scheduled before suspect knew"),
    ],
    anchors: [0, 7],
    tier: ColdCases,
    title: "The Vanishing Witness",
    theme: "Witness intimidation",
  }
}
