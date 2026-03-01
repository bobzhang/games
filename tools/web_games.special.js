"use strict";

/**
 * Optional special-case overrides for web builds.
 *
 * `games[<name>]` fields:
 * - skip: boolean
 * - pkgPath: string
 * - outDirName: string
 * - outDir: string (absolute or repo-relative)
 * - extraArgs: string[]
 */
module.exports = {
  games: {
    // FIXME(web): Re-enable once async TLS symbols are supported in web linking.
    // Current failure: undefined moonbitlang_async_tls_ssl_* symbols during wasm link.
    raylib_network_curl: {
      skip: true,
      reason: "web link missing async TLS symbols (moonbitlang_async_tls_ssl_*)",
    },

    // Example:
    // raylib_example: {
    //   outDirName: "raylib_example_mobile",
    //   extraArgs: ["--some-flag"],
    // },
  },

  /**
   * Optional dynamic hook for ad-hoc logic.
   *
   * @param {string} game
   * @param {{game:string,pkgPath:string,outDir:string,extraArgs:string[],skip:boolean}} plan
   * @returns {object|void}
   */
  resolveGame(game, plan) {
    // Example:
    // if (game === "raylib_example") {
    //   return { ...plan, skip: true };
    // }
    return plan;
  },
};
