export const activateEmail = (firstName, selector, verifier, host) => `
  <html>
    <body>
      <p>Hi, ${ firstName }.</p>
      <p>Thanks for registering with us. You're almost ready to get up and running with fling.work</p>
      <p>
        <a href="${ host }/activate/?code=${ encodeURIComponent(selector) }.${ encodeURIComponent(verifier) }">Click here to activate your account.</a> You won't be able to log in until your account has been activated. Alternatively, copy and paste this link to your browser: ${ host }/activate/?code=${ encodeURIComponent(selector) }.${ encodeURIComponent(verifier) }
      </p>
      <p>If you didn't register an account with this email address, then you may be the target of a phishing attack. Please ignore this email. </p>
      <p>Best regards, </p>
      </p><strong>The fling.work team</p>
    </body>
  </html>
`;