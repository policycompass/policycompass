"""Add or override py.test fixtures for all tests in this directory."""
import pytest


@pytest.fixture(scope='session')
def splinter_browser_load_condition():
    """Browser condition fixture to check that html page is fully loaded."""
    def is_page_loaded(browser):
        code = 'document.readyState === "complete";'
        return browser.evaluate_script(code)
    return is_page_loaded
