// ==UserScript==
// @name         Linkedin Hide jobs sidebar
// @namespace    http://tampermonkey.net/
// @version      0.2
// @description  Save the useful space in vertical desktop mode in Linkedin hiding the sidebar with jobs
// @author       Maksim Chistiakov https://github.com/mxchist
// @match        https://www.linkedin.com/jobs/search-results/*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=linkedin.com
// @grant        none
// @run-at       document-idle
// ==/UserScript==

(function() {
    'use strict';

    // Create the checkbox
    let toggleJobsSidebar = document.createElement('input');
    toggleJobsSidebar.type = 'checkbox';
    toggleJobsSidebar.id = 'toggle-jobs-sidebar';
    toggleJobsSidebar.checked = true;

    // Get the start node
    const observer = new MutationObserver((mutations) => {
        if (mutations.length > 0) {
            let container = document.querySelector('#workspace > div > div:nth-child(2)');
            let header = container.querySelector(':scope > header > div > div');
            if (header.childNodes.length == 2) {

                // Here three steps in a single long line:
                // 1. Get a node of the header in container.
                // 2. Get a 2nd (and the last) element in the header.
                // 3. Insert the checkbox that was created above.
                header.insertBefore(
                    toggleJobsSidebar,
                    header.querySelector(':scope > div:nth-child(2)')
                );

                let jobsBoard = container.querySelector(':scope > div');
                toggleJobsSidebar.addEventListener('change', () => {
                    if (toggleJobsSidebar.checked) {
                        jobsBoard.style.removeProperty('grid-template-columns');
                    } else {
                        jobsBoard.style.setProperty('grid-template-columns', '0');
                    }
                })
            }
        }
    });

    observer.observe(document.body, {
        childList: true,
        subtree: true,
        attributes: false,
        characterData: false,
    });
})();
