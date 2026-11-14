#!/usr/bin/env python3
"""Browser regressions for the standalone architecture atlas (Playwright)."""
import json
import re
import tempfile
from pathlib import Path
from playwright.sync_api import sync_playwright

ROOT = Path(__file__).resolve().parents[1]

with sync_playwright() as playwright:
    browser = playwright.chromium.launch()
    page = browser.new_page(viewport={"width": 1200, "height": 900}, permissions=["clipboard-read", "clipboard-write"])
    errors = []
    page.on("pageerror", lambda error: errors.append(str(error)))
    page.goto((ROOT / "docs/nocto-architecture-atlas.html").as_uri())
    assert page.locator(".node").count() == 10
    page.get_by_role("button", name="Center selection").click()
    assert page.locator("#viewport").get_attribute("transform") == "translate(30 307) scale(1)"
    page.get_by_role("button", name="Copy node JSON").click()
    assert json.loads(page.evaluate("navigator.clipboard.readText()"))["id"] == "ui"
    page.get_by_role("button", name="Fit diagram").click()
    box = page.locator("#diagram").bounding_box()
    x, y = box["x"] + 25, box["y"] + 25
    page.mouse.move(x, y)
    page.mouse.down()
    page.mouse.move(x + 80, y + 40)
    page.mouse.up()
    matrix = page.locator("#diagram").evaluate("s => {const m=s.getScreenCTM(); return {a:m.a,d:m.d}}")
    transform = page.locator("#viewport").get_attribute("transform")
    tx, ty = map(float, re.search(r"translate\(([^ ]+) ([^)]+)\)", transform).groups())
    assert abs(tx - 80 / matrix["a"]) < 0.01, transform
    assert abs(ty - 40 / matrix["d"]) < 0.01, transform
    # Zoom must preserve the world point under the cursor in a letterboxed SVG.
    page.get_by_role("button", name="Fit diagram").click()
    anchor = page.locator("#diagram").evaluate("(s, point) => {const p=s.createSVGPoint(); p.x=point.x; p.y=point.y; const q=p.matrixTransform(s.getScreenCTM().inverse()); return {x:q.x,y:q.y}}", {"x": x, "y": y})
    page.mouse.move(x, y)
    page.mouse.wheel(0, -100)
    page.wait_for_function("document.querySelector('#viewport').getAttribute('transform').includes('scale(1.08)')")
    transform = page.locator("#viewport").get_attribute("transform")
    tx, ty = map(float, re.search(r"translate\(([^ ]+) ([^)]+)\)", transform).groups())
    assert abs(tx + anchor["x"] * 0.08) < 0.01
    assert abs(ty + anchor["y"] * 0.08) < 0.01
    with page.expect_download() as result:
        page.get_by_role("button", name="Export SVG").click()
    with tempfile.TemporaryDirectory() as directory:
        exported = Path(directory) / "diagram.svg"
        result.value.save_as(exported)
        standalone = browser.new_page()
        standalone.goto(exported.as_uri())
        assert standalone.locator(".edge").first.evaluate("e => getComputedStyle(e).fill") == "none"
        assert standalone.locator(".title").first.evaluate("e => getComputedStyle(e).fill") == "rgb(242, 243, 248)"
        assert standalone.locator(".node.planned rect").evaluate("e => getComputedStyle(e).strokeDasharray") != "none"
    # Clipboard rejection must still provide a usable JSON download.
    page.evaluate("Object.defineProperty(navigator, 'clipboard', {value: undefined, configurable: true})")
    with page.expect_download() as fallback:
        page.get_by_role("button", name="Copy node JSON").click()
    assert json.loads(Path(fallback.value.path()).read_text())["id"] == "ui"
    for width in (390, 1600):
        page.set_viewport_size({"width": width, "height": 900})
        page.get_by_role("button", name="Reset view").click()
        assert page.locator(".node").count() == 10
    assert not errors, errors
    browser.close()
print("Atlas browser regressions passed")
