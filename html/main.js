window.addEventListener('message', function(event) {
    if (event.data.type === "open") {
        // Display the UI
        document.getElementById("points-ui").style.display = "block";  
        document.getElementById("title").innerHTML = event.data.title;
        document.getElementById("message").innerHTML = event.data.message;
    } else if (event.data.type === "close") {
        // Hide the UI
        document.getElementById("points-ui").style.display = "none";  
    }
});

// Close the menu when the "Close" button is clicked
document.getElementById('close-btn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/closepoints`, {
        method: 'POST',
    });
});