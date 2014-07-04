"""Acceptances tests using py.test fixtures.

All fixtures from ../conftest.py and :mod: `pytest_splinter.plugin` are
available.

The test case structure should follow the If-When-Then pattern.

"""

#########
# Tests #
#########


def test_user_want_to_explore_news(browser):
    # import ipdb; ipdb.set_trace() # python interactive debugger
    visit_page(browser, 'the-project')
    input_in_search_box_and_press_enter(browser, 'Plenar Meeting')
    is_on_page(browser, 'Search')
    is_in_listing(browser, '2nd Plenary Meeting')


###########################
# Common helper functions #
###########################


def visit_page(browser, url):
    browser.visit('http://policycompass.eu')
    browser.browser.click_link_by_partial_href('the-project')


def input_in_search_box_and_press_enter(browser, text):
    button = browser.browser.find_by_id('s').first
    button.fill(text + '\r')


def is_on_page(browser, partial_url):
    assert partial_url in browser.browser.url


def is_in_listing(browser, heading):
    assert browser.browser.is_text_present(heading)
