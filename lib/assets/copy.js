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

export const orgAccessEmail = (adminFirstName, adminLastName, userFirstName, userLastName, orgName, selector, verifier, host) => `
  <html>
    <body>
      <p>Hi, ${ adminFirstName }.</p>
      <p>This email is to let you know that ${userFirstName + ' ' + userLastName} has requested access to your fling.work organization: <strong>${orgName}</strong></p>
      <p>To allow this user access to your organization click <a href="${ host }/validateorg/?code=${ encodeURIComponent(selector) }.${ encodeURIComponent(verifier) }">here</a>. Alternatively, copy and paste this link to your browser: ${ host }/validateorg/?code=${ encodeURIComponent(selector) }.${ encodeURIComponent(verifier) }
      <p>${userFirstName + ' ' + userLastName} will not be able to continue using fling.work until you have validated their access. If you do not wish to allow access to this person, you can simply ignore this email.</p>
      <p>Best regards, </p>
      </p><strong>The fling.work team</p>
    </body>
  </html>
`;