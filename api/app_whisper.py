# Copyright 2025 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# REST API for transcription server


from flask import Flask, Response, request
import io
import os
import tempfile
import shutil

from transformers import WhisperProcessor, WhisperForConditionalGeneration
import soundfile as sf

########### ASR WITH WHISPER #####################################################
# set this to whatever whisper model type you have fine-tuned
# we use that to load the processor
BASE_WHISPER_MODEL_TYPE = "openai/whisper-small"

# set language to whatever language you used in fine-tuning the model
LANGUAGE = "en"

# limit transcription to this many subwords
MAX_NEW_TOKENS = 256

# model needs to contain the json files and pytorch bin file
CUSTOM_WHISPER_MODEL_PATH = 'custom_tiny_whisper_model'

# load processor and model
whisper_processor = WhisperProcessor.from_pretrained(
    BASE_WHISPER_MODEL_TYPE,
    language=LANGUAGE, 
    task="transcribe")
print('Successfully loaded processor for model:', BASE_WHISPER_MODEL_TYPE)

whisper_model = WhisperForConditionalGeneration.from_pretrained(
    CUSTOM_WHISPER_MODEL_PATH, 
    local_files_only=True, 
    force_download=False)

# # or use the unadapted model
# whisper_model = WhisperForConditionalGeneration.from_pretrained(BASE_WHISPER_MODEL_TYPE)
print('Successfully loaded custom ASR model from path:', CUSTOM_WHISPER_MODEL_PATH)

def whisper_transcribe(audio_file):
  """transcribe single audio, needs to be resampled to 16khz!"""
  audio_array, sampling_rate = sf.read(audio_file)
  input_features = whisper_processor(audio_array, sampling_rate=sampling_rate, return_tensors="pt").input_features
  predicted_ids = whisper_model.generate(
      input_features, 
      max_new_tokens=MAX_NEW_TOKENS,
      language=LANGUAGE, 
      task="transcribe")
  transcription = whisper_processor.batch_decode(predicted_ids, skip_special_tokens=True)
  return transcription[0].strip()
################################################################


app = Flask(__name__)

@app.route('/transcribe', methods=['POST'])
def transcribe():
    # test with:
    #  curl -F wav=@/path/to/16khz.wav http://localhost:8080/transcribe
    
    # store uploaded file temporarily for processing
    _, tmp_wav_file = tempfile.mkstemp()
    audio = request.files['wav']

    # Note: we are expecting mono 16khz audios (can extend to convert if needed)
    if not audio.filename.endswith('.wav'):
        return {"response": "invalid file, must be WAV"}
    audio.save(dst=tmp_wav_file)
    print('>> Successfully uploaded audio file %s to %s' %(audio.filename, tmp_wav_file))    
    
    # transcribe
    pred = whisper_transcribe(audio_file=tmp_wav_file)

    # remove file and copy
    os.remove(tmp_wav_file)    
    return {"response": "success!", "transcript": pred}


if __name__ == '__main__':
    # app.run(debug=True, host='127.0.0.1', port=8080)    
    app.run(debug=True, host='10.0.0.194', port=8082)    