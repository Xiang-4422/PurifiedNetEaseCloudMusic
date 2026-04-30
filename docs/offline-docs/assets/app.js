(function () {
  "use strict";

  var markdown = window.DOCS_MARKDOWN || "";
  var documentRoot = document.getElementById("document");
  var tocRoot = document.getElementById("toc");
  var searchInput = document.getElementById("searchInput");
  var searchResults = document.getElementById("searchResults");
  var searchStatus = document.getElementById("searchStatus");
  var backToTop = document.getElementById("backToTop");
  var menuButton = document.getElementById("menuButton");

  function escapeHtml(value) {
    return String(value).replace(/[&<>"']/g, function (character) {
      return {
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': "&quot;",
        "'": "&#39;",
      }[character];
    });
  }

  function inlineMarkdown(value) {
    if (!window.marked || !window.marked.parseInline) {
      return escapeHtml(value);
    }
    return window.marked.parseInline(value.replace(/\n+/g, " "));
  }

  function preprocessDocsifyBlocks(source) {
    return source
      .split(/\n{2,}/)
      .map(function (block) {
        var trimmed = block.trimStart();
        if (trimmed.indexOf("!>") === 0) {
          return '<div class="docsify-alert">' + inlineMarkdown(trimmed.replace(/^!>\s*/, "")) + "</div>";
        }
        if (trimmed.indexOf("?>") === 0) {
          return '<div class="docsify-alert warn">' + inlineMarkdown(trimmed.replace(/^\?>\s*/, "")) + "</div>";
        }
        return block;
      })
      .join("\n\n");
  }

  function slugify(text) {
    var slug = text
      .trim()
      .toLowerCase()
      .normalize("NFKD")
      .replace(/[^\p{L}\p{N}]+/gu, "-")
      .replace(/^-+|-+$/g, "");
    return slug || "section";
  }

  function buildHeadingIds() {
    var seen = {};
    var headings = Array.prototype.slice.call(documentRoot.querySelectorAll("h1, h2, h3, h4"));
    headings.forEach(function (heading) {
      var base = slugify(heading.textContent);
      var count = seen[base] || 0;
      seen[base] = count + 1;
      heading.id = count ? base + "-" + count : base;
    });
    return headings;
  }

  function buildToc(headings) {
    tocRoot.innerHTML = headings
      .filter(function (heading) {
        return heading.tagName !== "H4";
      })
      .map(function (heading) {
        var depth = Number(heading.tagName.slice(1));
        return (
          '<a class="depth-' +
          depth +
          '" href="#' +
          encodeURIComponent(heading.id) +
          '">' +
          escapeHtml(heading.textContent) +
          "</a>"
        );
      })
      .join("");
  }

  function getSections(headings) {
    return headings.map(function (heading, index) {
      var next = headings[index + 1];
      var text = heading.textContent + "\n";
      var node = heading.nextElementSibling;
      while (node && node !== next) {
        text += " " + node.textContent;
        node = node.nextElementSibling;
      }
      return {
        id: heading.id,
        title: heading.textContent,
        text: text.replace(/\s+/g, " ").trim(),
        depth: Number(heading.tagName.slice(1)),
      };
    });
  }

  function updateActiveLink() {
    var headings = Array.prototype.slice.call(documentRoot.querySelectorAll("h1, h2, h3, h4"));
    var active = headings[0];
    headings.forEach(function (heading) {
      if (heading.getBoundingClientRect().top < 120) {
        active = heading;
      }
    });
    Array.prototype.forEach.call(tocRoot.querySelectorAll("a"), function (link) {
      link.classList.toggle("active", active && link.getAttribute("href") === "#" + encodeURIComponent(active.id));
    });
    backToTop.classList.toggle("visible", window.scrollY > 500);
  }

  function bindSearch(sections) {
    searchInput.addEventListener("input", function () {
      var query = searchInput.value.trim().toLowerCase();
      if (!query) {
        searchResults.hidden = true;
        searchResults.innerHTML = "";
        searchStatus.textContent = "";
        return;
      }

      var matches = sections
        .map(function (section) {
          var text = section.text.toLowerCase();
          var title = section.title.toLowerCase();
          var titleIndex = title.indexOf(query);
          var textIndex = text.indexOf(query);
          if (titleIndex === -1 && textIndex === -1) {
            return null;
          }
          var start = Math.max(0, (textIndex === -1 ? 0 : textIndex) - 36);
          var snippet = section.text.slice(start, start + 110);
          return {
            id: section.id,
            title: section.title,
            snippet: snippet,
            score: titleIndex === -1 ? 1 : 0,
          };
        })
        .filter(Boolean)
        .sort(function (left, right) {
          return left.score - right.score;
        })
        .slice(0, 24);

      searchStatus.textContent = matches.length ? "显示前 " + matches.length + " 个匹配" : "没有匹配结果";
      searchResults.hidden = !matches.length;
      searchResults.innerHTML = matches
        .map(function (match) {
          return (
            '<a href="#' +
            encodeURIComponent(match.id) +
            '"><strong>' +
            escapeHtml(match.title) +
            "</strong><span>" +
            escapeHtml(match.snippet) +
            "</span></a>"
          );
        })
        .join("");
    });
  }

  function bindInternalLinks() {
    document.addEventListener("click", function (event) {
      var link = event.target.closest("a[href^='#']");
      if (!link) {
        return;
      }
      var target = document.getElementById(decodeURIComponent(link.getAttribute("href").slice(1)));
      if (!target) {
        return;
      }
      event.preventDefault();
      document.body.classList.remove("nav-open");
      target.scrollIntoView({ behavior: "smooth", block: "start" });
      history.replaceState(null, "", "#" + encodeURIComponent(target.id));
    });
  }

  function render() {
    if (!window.marked || !window.marked.parse) {
      documentRoot.innerHTML = '<p class="docsify-alert warn">本地 Markdown 渲染库加载失败。</p>';
      return;
    }

    window.marked.setOptions({
      gfm: true,
      breaks: false,
      headerIds: false,
      mangle: false,
    });

    documentRoot.innerHTML = window.marked.parse(preprocessDocsifyBlocks(markdown));
    var headings = buildHeadingIds();
    buildToc(headings);
    bindSearch(getSections(headings));
    bindInternalLinks();
    updateActiveLink();
  }

  menuButton.addEventListener("click", function () {
    document.body.classList.toggle("nav-open");
  });

  backToTop.addEventListener("click", function () {
    window.scrollTo({ top: 0, behavior: "smooth" });
  });

  window.addEventListener("scroll", updateActiveLink, { passive: true });
  render();
})();
