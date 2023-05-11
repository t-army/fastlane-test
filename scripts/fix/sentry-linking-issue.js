// https://docs.sentry.io/platforms/react-native/troubleshooting/#react-native-069-and-higher

const fs = require('fs');

const content = `module.exports = {
  dependency: {
    platforms: {
      ios: {},
      android: {
        packageInstance: 'new RNSentryPackage()'
      }
    }
  }
};
`;

fs.writeFile('node_modules/@sentry/react-native/react-native.config.js', content, 'utf-8', error => {
  if (error) {
    console.log(error);
  }
});
