import { createRoot } from 'react-dom/client';
import { App } from '../App';
import { Provider } from 'react-redux';
import { store } from '../state/store';
import { ThemeProvider, createTheme } from '@mui/material/styles';

// Create a custom theme with Open Sans font to match AWS console style
const theme = createTheme({
  typography: {
    fontFamily: '"Open Sans", sans-serif',
  },
});

const container = document.getElementById('root');

if(container) {
  const root = createRoot(container);
  root.render(
    <ThemeProvider theme={theme}>
      <Provider store={store}>
        <App />
      </Provider>
    </ThemeProvider>
  )
}
