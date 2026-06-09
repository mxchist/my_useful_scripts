// ==UserScript==
// @name         Rearrange Linkedin Feed for vertical FHD monitors
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  Save the useful space in vertical Linkedin mode removing the right column with puzzle games and proposed contacts
// @author       Maksim Chistiakov https://github.com/mxchist
// @match        https://www.linkedin.com/feed/
// @icon         https://www.google.com/s2/favicons?sz=64&domain=linkedin.com
// @grant        none
// @run-at       document-idle
// ==/UserScript==

(function() {
    'use strict';

    //console.log('ReArrange Linkedin Feed script: started');

    let feedWasReArranged = false;

    function reArrangeFeed() {
        //if (feedWasReArranged) return;
        //console.log('ReArrange Linkedin Feed script: fall into reArrangeFeed()');
        // Move nodes from the left columb to the right column, and remove the left column
        let container = document.querySelector('#workspace > div > div');
        let leftColumn = container.children[0];
        let firstDiv = leftColumn.querySelector(':scope > div > div > div');
        let rightColumn = container.children[2];

        if (rightColumn) {
            rightColumn.querySelectorAll(':scope > div > div').forEach(div => firstDiv.appendChild(div));
            rightColumn.remove();
            feedWasReArranged = true;
        } else {
            console.warn('ReArrange Linkedin: it seems the script has already worked here. Nothing to do.');
        }

        // Stretch the center
        // This approach is wobbly, because Linkedin dinamically names its CSS classes, and
        // seems like they comes from cross-domain stylesheet. Try to remove these
        // classes by the known indices
        let centerColumn = document.querySelector('#workspace > div > div > section');
        [centerColumn.classList[4], centerColumn.classList[2]].forEach((styleName, _index) => {
            centerColumn.classList.remove(styleName);
        });
        //centerColumn.style.setProperty('grid-column-end', 'col-end 22', 'important');
    }

    let observer = new MutationObserver(reArrangeFeed);
    observer.observe(document.body, {
        'childList': true,
        'subtree': true
    });

    //reArrangeFeed();

    //console.log('ReArrange Linkedin Feed script finished');
})();