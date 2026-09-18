document.getElementById('open-fap-btn').addEventListener('click', () => {
  chrome.tabs.create({ url: 'https://fap.fpt.edu.vn/' });
});
