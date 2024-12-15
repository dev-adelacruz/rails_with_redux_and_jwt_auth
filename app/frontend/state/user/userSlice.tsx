import { createSlice } from "@reduxjs/toolkit";

const initialState: UserState = {
  isSignedIn: false
};

const userSlice = createSlice({
  name: 'User',
  initialState,
  reducers: {
    signIn: (state) => {
      state.isSignedIn = true
    },
    signOut: (state) => {
      state.isSignedIn = false
    }
  }
})

export const { signIn, signOut } = userSlice.actions;
export default userSlice.reducer;